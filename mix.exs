defmodule SendGrid.Mixfile do
  use Mix.Project

  def project do
    [app: :sendgrid,
     version: "2.0.0",
     elixir: "~> 1.4",
     package: package(),
     compilers: compilers(Mix.env),
     description: description(),
     source_url: project_url(),
     homepage_url: project_url(),
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
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
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev, :test], runtime: false},
      {:earmark,      "~> 1.2",  only: :dev},
      {:ex_doc,       "~> 0.19", only: :dev},
      {:jason, "~> 1.1"},
      {:phoenix,      "~> 1.2", only: :test},
      {:phoenix_html, "~> 2.9", only: :test},
      {:tesla, "~> 1.2"}
    ]
  end

  defp description do
    """
    A wrapper for SendGrid's API to create composable emails.
    """
  end

  defp project_url do
    """
    https://github.com/alexgaribay/sendgrid_elixir
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "LICENSE", "README.md"],
      maintainers: ["Alex Garibay"],
      licenses: ["MIT"],
      links: %{"GitHub" => project_url()}
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
