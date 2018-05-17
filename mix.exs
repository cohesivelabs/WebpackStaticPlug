defmodule WebpackStatic.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :webpack_static_plug,
      version: "0.2.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "WebpackStaticPlug",
      source_url: "https://github.com/jmartin84/WebpackStaticPlug",
      description: "Phoenix Plug to proxy assets served by the webpack dev server",
      package: package(),
      docs: [main: "WebpackStatic.Plug", extras: ["README.md"]],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
    ]
  end

  defp package do
    [
      maintainers: ["jmartin84"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jmartin84/WebpackStaticPlug"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:httpotion, :plug]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpotion, "~> 3.1.0"},
      {:poison, "~> 3.1"},
      {:plug, "~> 1.0"},
      {:dialyzex, "~> 1.1.0", only: :dev},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:bypass, "~> 0.8", only: :test},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:excoveralls, "~> 0.8", only: :test}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
