defmodule SendGrid.Mixfile do
  use Mix.Project

  @source_url "https://github.com/alexgaribay/sendgrid_elixir"
  @version "2.0.0"

  def project do
    [
      app: :sendgrid,
      version: @version,
      elixir: "~> 1.4",
      package: package(),
      compilers: compilers(Mix.env()),
      description: description(),
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      xref: [exclude: [Phoenix.View]],
      preferred_cli_env: [
        dialyzer: :test,
        "test.integration": :test
      ],
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [
        :logger
      ]
    ]
  end

  # Use Phoenix compiler depending on environment.
  defp compilers(:test), do: [:phoenix] ++ Mix.compilers()
  defp compilers(_), do: Mix.compilers()

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:jason, "~> 1.1"},
      {:tesla, "~> 1.2"},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:phoenix, "~> 1.2", only: :test},
      {:phoenix_html, "~> 2.9", only: :test}
    ]
  end

  defp docs do
    [
      extras: ["CHANGELOG.md", "README.md"],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      homepage_url: @source_url
    ]
  end

  defp description do
    """
    A wrapper for SendGrid's API to create composable emails.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "LICENSE", "README.md"],
      maintainers: ["Alex Garibay"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/sendgrid/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end

  defp aliases do
    [
      test: [
        "test --exclude integration"
      ],
      "test.integration": [
        "test --only integration"
      ]
    ]
  end
end
