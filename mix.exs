# The MIT License (MIT).
#
# Copyright (c) 2024-2025 Almaz Ilaletdinov <a.ilaletdinov@yandex.ru>
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

defmodule ReviveScheduler.MixProject do
  use Mix.Project

  def project do
    [
      app: :revive_scheduler,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ReviveScheduler.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "== 1.7.21"},
      {:phoenix_ecto, "== 4.6.4"},
      {:ecto_sql, "== 3.13.0"},
      {:postgrex, "== 0.20.0"},
      {:phoenix_html, "== 4.2.1"},
      # TODO bump on release to {:phoenix_live_view, "~> 1.0.0"},
      {:phoenix_live_view, "== 1.0.17", override: true},
      {:phoenix_live_dashboard, "== 0.8.7"},
      {:esbuild, "== 0.10.0", runtime: Mix.env() == :dev},
      {:swoosh, "== 1.19.2"},
      {:finch, "== 0.19.0"},
      {:telemetry_metrics, "== 1.1.0"},
      {:telemetry_poller, "== 1.2.0"},
      {:gettext, "== 0.26.2"},
      {:jason, "== 1.4.4"},
      {:dns_cluster, "== 0.2.0"},
      {:bandit, "== 1.7.0"},
      {:quantum, "== 3.5.3"},
      {:crontab, "== 1.1.14"},
      {:httpoison, "== 2.2.3"},
      {:dotenvy, "== 1.1.0"},
      # Deb dependencies
      {:phoenix_live_reload, "== 1.6.0", only: :dev},
      {:credo, "== 1.7.12", only: :dev},
      {:recode, "== 0.7.3", only: :dev},
      {:floki, "== 0.38.0", only: :test},
      {:igniter, "== 0.4.1", only: :dev}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      lint: ["format", "credo --strict"],
      "assets.setup": ["esbuild.install --if-missing"],
      "assets.build": ["esbuild revive_scheduler"],
      "assets.deploy": [
        "esbuild revive_scheduler --minify",
        "phx.digest"
      ]
    ]
  end
end
