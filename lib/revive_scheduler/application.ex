# The MIT License (MIT).
#
# Copyright (c) 2024 Almaz Ilaletdinov <a.ilaletdinov@yandex.ru>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
# OR OTHER DEALINGS IN THE SOFTWARE.

defmodule ReviveScheduler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Crontab.CronExpression
  alias ReviveScheduler.Job
  alias ReviveScheduler.PingRepo
  alias ReviveScheduler.Repo
  use Gettext, backend: MyApp.Gettext

  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      ReviveSchedulerWeb.Telemetry,
      ReviveScheduler.Repo,
      {DNSCluster, query: Application.get_env(:revive_scheduler, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ReviveScheduler.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ReviveScheduler.Finch},
      # Start a worker by calling: ReviveScheduler.Worker.start_link(arg)
      # {ReviveScheduler.Worker, arg},
      # Start to serve requests, typically the last entry
      ReviveSchedulerWeb.Endpoint,
      ReviveScheduler.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ReviveScheduler.Supervisor]
    result = Supervisor.start_link(children, opts)
    load_jobs_from_db()
    result
  end

  def load_jobs_from_db do
    Repo.all(Job)
    |> Enum.each(fn job ->
      create_quantum_job(
        job.repo_id,
        job.cron_expression
      )
    end)
  end

  defp create_quantum_job(repo_id, cron_expression) do
    {:ok, parsed_cron} = CronExpression.Parser.parse(cron_expression)
    job_name = String.to_atom("analyze repo <#{repo_id}>")

    ReviveScheduler.Scheduler.new_job()
    |> Quantum.Job.set_name(job_name)
    |> Quantum.Job.set_schedule(parsed_cron)
    |> Quantum.Job.set_task(fn -> PingRepo.ping(repo_id) end)
    |> ReviveScheduler.Scheduler.add_job()

    ReviveScheduler.Scheduler.activate_job(job_name)
    Logger.info("Scheduling for repo <#{repo_id}> started from db")
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ReviveSchedulerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
