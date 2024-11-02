defmodule ReviveScheduler.PingRepo do
  alias HTTPoison
  require Logger

  def ping(repo_id) do
    url = "https://revive-code-bot.ilaletdinov.ru/process-repo/#{repo_id}"
    case HTTPoison.post(url, "", []) do
        {:ok, %HTTPoison.Response{status_code: 201}} ->
          Logger.info("Request for process repo <#{repo_id}> sended")
        {:ok, %HTTPoison.Response{status_code: status_code}} ->
          Logger.info("Fail request to repo processor app repo <#{repo_id}>. Status: #{status_code}")
        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.info("Fail request to repo processor app repo <#{repo_id}>. Reason: #{reason}")
    end
  end
end
