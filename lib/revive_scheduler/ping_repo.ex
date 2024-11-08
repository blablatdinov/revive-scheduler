defmodule ReviveScheduler.PingRepo do
  @moduledoc """
  Ping revive bot for process repo
  """
  alias HTTPoison
  require Logger

  def ping(repo_id) do
    url = "https://revive-code-bot.ilaletdinov.ru/process-repo/#{repo_id}"
    revive_app_token = Application.get_env(:revive_scheduler, :revive_app_token)

    case HTTPoison.post(url, "", [{"Authorization", "Basic #{revive_app_token}"}]) do
      {:ok, %HTTPoison.Response{status_code: 201}} ->
        Logger.info("Request for process repo <#{repo_id}> sended")

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Logger.info(
          "Fail request to repo processor app repo <#{repo_id}>. Status: #{status_code}"
        )

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.info("Fail request to repo processor app repo <#{repo_id}>. Reason: #{reason}")
    end
  end
end
