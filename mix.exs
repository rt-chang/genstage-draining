defmodule GenStageDraining.MixProject do
  use Mix.Project

  def project do
    [
      app: :genstage_draining,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {GenStageDraining.Application, []},
      extra_applications: [:logger_file_backend]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_stage, "~> 1.0.0"},
      {:logger_file_backend, "~> 0.0.10"}
    ]
  end
end
