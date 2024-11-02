defmodule ReviveScheduler.ApplicationTest do
  alias Ecto.Adapters
  use ExUnit.Case, async: false
  alias ReviveScheduler.Job
  alias ReviveScheduler.Repo
  alias ReviveScheduler.Scheduler

  use ReviveSchedulerWeb.ConnCase
  alias Quantum.Job, as: QuantumJob

  setup do
    Repo.delete_all(Job)
    Scheduler.delete_all_jobs()
    :ok
  end

  test "Test apps scheduled on load app" do
    Adapters.SQL.query(
      Repo,
      Enum.join(
        [
          "INSERT INTO gh_repos (id, full_name, has_webhook, installation_id)",
          "VALUES (1, 'blablatdinov/ondivi', 't', 1)"
        ],
        " "
      )
    )

    %Job{repo_id: 1, cron_expression: "* * * * *"}
    |> Repo.insert!()

    ReviveScheduler.Application.load_jobs_from_db()

    assert Scheduler.find_job(String.to_atom("analyze repo <1>")).state == :active
  end
end
