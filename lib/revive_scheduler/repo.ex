defmodule ReviveScheduler.Repo do
  use Ecto.Repo,
    otp_app: :revive_scheduler,
    adapter: Ecto.Adapters.Postgres
end
