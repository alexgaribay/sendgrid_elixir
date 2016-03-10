defmodule SendgridElixir.Mixfile do
  use Mix.Project

  def project do
    [app: :sendgrid,
     version: "0.0.2",
     elixir: "~> 1.2",
     package: package,
     description: description,
     source_url: project_url,
     homepage_url: project_url,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      applications: [
        :logger,
        :httpoison
      ]
    ]
  end

  defp deps do
    [
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:httpoison, "~> 0.8.0"},
      {:poison, "~> 1.5"}
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
      links: %{"GitHub" => project_url}
    ]
  end

end
