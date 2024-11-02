defmodule ReviveScheduler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias ReviveScheduler.{Repo, Job, Scheduler}
  alias Crontab.CronExpression
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

  def load_jobs_from_db() do
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

    job =
      ReviveScheduler.Scheduler.new_job()
      |> Quantum.Job.set_name(job_name)
      |> Quantum.Job.set_schedule(parsed_cron)
      |> Quantum.Job.set_task(fn -> Logger.info("process repo id=#{repo_id}") end)
      |> ReviveScheduler.Scheduler.add_job()

    ReviveScheduler.Scheduler.activate_job(job_name)
    Logger.info("Task started")
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ReviveSchedulerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
