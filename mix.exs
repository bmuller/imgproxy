defmodule Imgproxy.MixProject do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :imgproxy,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
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

  def description do
    """
    This is a description
    """
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
      {:ex_doc, "~> 0.18", only: :dev}
    ]
  end
end
