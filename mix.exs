defmodule Imgproxy.MixProject do
  use Mix.Project

  @version "2.0.0"
  @source_url "https://github.com/bmuller/imgproxy"

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
      source_url: @source_url,
      docs: docs(),
      preferred_cli_env: [test: :test, "ci.test": :test]
    ]
  end

  defp docs do
    [
      extra_section: "GUIDES",
      source_ref: "v#{@version}",
      source_url: @source_url,
      main: "readme",
      formatters: ["html"],
      extras: ["README.md"]
    ]
  end

  defp aliases do
    [
      "ci.test": [
        "format --check-formatted",
        "test",
        "credo"
      ]
    ]
  end

  def package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Brian Muller"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/bmuller/imgproxy",
        "imgproxy Site" => "https://imgproxy.net"
      }
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
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev}
    ]
  end
end
