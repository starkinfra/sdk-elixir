defmodule StarkInfra.MixProject do
  use Mix.Project

  def project do
    [
      app: :starkinfra,
      name: :starkinfra,
      version: "0.1.0",
      homepage_url: "https://starkinfra.com",
      source_url: "https://github.com/starkinfra/sdk-elixir",
      description: description(),
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  defp package do
    [
      maintainers: ["Stark Infra"],
      licenses: [:MIT],
      links: %{
        "StarkInfra" => "https://starkinfra.com",
        "GitHub" => "https://github.com/starkinfra/sdk-elixir"
      }
    ]
  end

  defp description do
    "SDK to make integrations with the Stark Infra API easier."
  end

  def application do
    [
      extra_applications: [:inets]
    ]
  end

  defp deps do
    [
      {:starkbank_ecdsa, "~> 1.1.0"},
      {:jason, "~> 1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
