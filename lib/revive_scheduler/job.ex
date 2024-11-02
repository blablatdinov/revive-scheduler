defmodule ReviveScheduler.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field :name, :string
    field :cron_expression, :string
    field :repo_id, :integer
  end

  def changeset(job, attrs) do
    job
    |> cast(attrs, [:name, :cron_expression, :repo_id])
    |> validate_required([:name, :cron_expression, :repo_id])
  end
end
