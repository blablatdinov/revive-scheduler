defmodule ReviveScheduler.JobControllerTest do
  use ReviveSchedulerWeb.ConnCase, async: true
  alias ReviveScheduler.Jobs

  describe "POST /api/jobs" do
    test "create cron job", %{conn: conn} do
      conn = post(conn, ~p"/api/jobs", %{
        "cron_expression" => "* * * * *",
        "repo_id" => 12,
      })

      assert json_response(conn, 200) == %{"status" => "Task created"}
    end
  end
end
