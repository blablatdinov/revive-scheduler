defmodule ReviveSchedulerWeb.JobController do
  import Crontab.CronExpression
  use ReviveSchedulerWeb, :controller
  alias ReviveScheduler.{Job, Repo}
  require Logger

  def create(conn, %{"cron_expression" => cron_expression, "repo_id" => repo_id}) do
    %Job{}
    |> Job.changeset(%{cron_expression: cron_expression, repo_id: repo_id})
    |> Repo.insert()

    create_quantum_job(cron_expression, repo_id)
    json(conn, %{status: "Task created"})
  end

  defp create_quantum_job(cron_expression, repo_id) do
    {:ok, parsed_cron} = Crontab.CronExpression.Parser.parse(cron_expression)
    job_name = String.to_atom("analyze repo <#{repo_id}>")

    job =
      ReviveScheduler.Scheduler.new_job()
      |> Quantum.Job.set_name(job_name)
      |> Quantum.Job.set_schedule(parsed_cron)
      |> Quantum.Job.set_task(fn -> Logger.info("process repo id=#{repo_id}") end)
      |> ReviveScheduler.Scheduler.add_job()

    ReviveScheduler.Scheduler.activate_job(job_name)
    ReviveScheduler.Scheduler.run_job(job_name)
    Logger.info("Task started")
  end
end
