defmodule BbEngine.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bb_engine,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [flags: [:unmatched_returns, :error_handling, :race_conditions, :underspecs]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "mix"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev},
      {:ex_guard, "~> 1.3", only: :dev},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false},
      {:eflame, "~> 1.0", only: :dev, runtime: false}
    ]
  end
end
