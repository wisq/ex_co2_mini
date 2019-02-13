defmodule ExCO2Mini.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_co2_mini,
      version: "0.1.2",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      description: description(),
      package: package(),
      compilers: [:elixir_make] ++ Mix.compilers()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    ExCO2Mini is a library to read carbon dioxide and temperature data from
    the CO2Mini USB sensor, also known as the RAD-0301.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Adrian Irving-Beer"],
      licenses: ["Apache Version 2.0"],
      links: %{GitHub: "https://github.com/wisq/ex_co2_mini"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:elixir_make, "~> 0.4", runtime: false},
      {:ex_doc, "~> 0.10", only: :dev},
      {:version_tasks, "~> 0.11.1", only: :dev}
    ]
  end
end
