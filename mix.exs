defmodule WebpackStatic.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :webpack_static_plug,
      version: "0.1.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "WebpackStaticPlug",
      source_url: "https://github.com/jmartin84/WebpackStaticPlug",
      description: "Phoenix Plug to proxy assets served by the webpack dev server",
      package: package(),
      docs: [main: "WebpackStatic.Plug",
              extras: ["README.md"]]
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
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
