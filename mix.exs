defmodule Cross.MixProject do
  use Mix.Project

  def project do
    [
      app: :cross,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Cross.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 4.0"},
      {:plug, "~> 1.7"},
      {:cowboy, "~> 2.5"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
