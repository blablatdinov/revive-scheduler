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

defmodule ReviveScheduler.PingRepo do
  @moduledoc """
  Ping revive bot for process repo
  """
  alias HTTPoison
  require Logger

  def ping(repo_id) do
    url = "https://revive-code-bot.ilaletdinov.ru/process-repo/#{repo_id}"

    case HTTPoison.post(url, "", []) do
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
