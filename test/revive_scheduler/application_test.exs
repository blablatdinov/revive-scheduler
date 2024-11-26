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

    %Job{repo_id: 1, cron_expression: "* * * * *", files_glob: "**/*"}
    |> Repo.insert!()

    ReviveScheduler.Application.load_jobs_from_db()

    assert Scheduler.find_job(String.to_atom("analyze repo <1>")).state == :active
  end
end
