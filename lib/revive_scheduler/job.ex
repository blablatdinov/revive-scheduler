defmodule ReviveScheduler.Job do
  @moduledoc """
  Job table schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "analyze_jobs_schedules" do
    field :cron_expression, :string
    field :repo_id, :integer
  end

  def changeset(job, attrs) do
    job
    |> cast(attrs, [:cron_expression, :repo_id])
    |> validate_required([:cron_expression, :repo_id])
  end
end
