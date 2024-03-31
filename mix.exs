defmodule Titles.MixProject do
  use Mix.Project

  def project do
    [
      app: :titles,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Titles, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:burrito, "~> 1.0"},
      {:mix_test_watch, "~> 1.2", only: :dev, runtime: false},
      {:tesla, "~> 1.8"},
      {:floki, "~> 0.36.1"},
      {:bypass, "~> 2.1", only: :test}
    ]
  end

  defp releases do
    [
      example_cli_app: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            macos_intel: [os: :darwin, cpu: :x86_64],
            macos_arm: [os: :darwin, cpu: :aarch64],
            linux: [os: :linux, cpu: :x86_64],
            windows: [os: :windows, cpu: :x86_64]
          ]
        ]
      ]
    ]
  end
end
