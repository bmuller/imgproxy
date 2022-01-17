defmodule ImgProxy.MixProject do
  use Mix.Project

  @source_url "https://github.com/bmuller/imgproxy"
  @version "3.0.1"

  def project do
    [
      app: :imgproxy,
      aliases: aliases(),
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: "imgproxy URL generator and helper functions",
      deps: deps(),
      package: package(),
      source_url: @source_url,
      docs: docs(),
      preferred_cli_env: [test: :test, "ci.test": :test]
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      extra_section: "GUIDES",
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
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
        "Changelog" => "https://hexdocs.pm/imgproxy/changelog.html",
        "GitHub" => @source_url,
        "imgproxy Site" => "https://imgproxy.net"
      }
    ]
  end

  def application do
    [
      extra_applications: [:crypto, :logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.25", only: :dev, runtime: false}
    ]
  end
end
