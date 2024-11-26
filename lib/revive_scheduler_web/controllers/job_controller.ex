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

defmodule ReviveSchedulerWeb.JobController do
  alias Crontab.CronExpression
  use ReviveSchedulerWeb, :controller
  alias ReviveScheduler.Job
  alias ReviveScheduler.PingRepo
  alias ReviveScheduler.Repo

  require Logger

  def create_or_update conn, %{"cron_expression" => cron_expression, "repo_id" => repo_id} do
    case Repo.get_by(Job, repo_id: repo_id) do
      nil -> create_quantum_job(cron_expression, repo_id)
      repo -> update_quantum_job(cron_expression, repo_id)
    end
    json(conn, %{status: "Task created"})
  end

  defp create_quantum_job(cron_expression, repo_id) do
    {:ok, parsed_cron} = CronExpression.Parser.parse(cron_expression)
    job_name = String.to_atom("analyze repo <#{repo_id}>")

    job =
      ReviveScheduler.Scheduler.new_job()
      |> Quantum.Job.set_name(job_name)
      |> Quantum.Job.set_schedule(parsed_cron)
      |> Quantum.Job.set_task(fn -> PingRepo.ping(repo_id) end)
      |> ReviveScheduler.Scheduler.add_job()

    ReviveScheduler.Scheduler.activate_job(job_name)
    Logger.info("Task for repo #{repo_id} created")
  end

  defp update_quantum_job(cron_expression, repo_id) do
    {:ok, parsed_cron} = CronExpression.Parser.parse(cron_expression)
    job_name = String.to_atom("analyze repo <#{repo_id}>")

    ReviveScheduler.Scheduler.find_job(job_name)
    |> Quantum.Job.set_schedule(parsed_cron)

    Logger.info("Task for repo #{repo_id} updated")
  end
end
