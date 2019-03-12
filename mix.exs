defmodule Imgproxy.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :imgproxy,
      aliases: aliases(),
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "imgproxy URL generator and helper functions",
      package: package(),
      source_url: "https://github.com/bmuller/imgproxy",
      docs: [
        extra_section: "GUIDES",
        source_ref: "v#{@version}",
        main: "overview",
        formatters: ["html", "epub"],
        extras: extras(),
        groups_for_extras: groups_for_extras()
      ]
    ]
  end

  defp extras do
    [
      "guides/overview.md"
    ]
  end

  defp aliases do
    [
      test: [
        "format --check-formatted",
        "test",
        "credo"
      ]
    ]
  end

  defp groups_for_extras do
    [
      Introduction: ~r/guides\/introduction\/.*/
    ]
  end

  def package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Brian Muller"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/bmuller/imgproxy"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.18", only: :dev},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false}
    ]
  end
end
