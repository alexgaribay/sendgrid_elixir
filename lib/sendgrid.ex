defmodule SendGrid do
  @moduledoc """
  Base module for interacting with SendGrid's API. A configured API key must
  be provided in your applications project's configuration.

  ## Configuration

  You must provide a configuration which includes your `api_key`.

  ```
  config :sendgrid,
    api_key: "sendgrid_api_key"
  ```
  """

  use HTTPoison.Base

  @api_url "https://api.sendgrid.com"

  if !Application.get_env(:sendgrid, :api_key), do: raise "SendGrid is not configured."

  defp process_url(url) do
    @api_url <> url
  end

  # Default headers to be sent.
  defp base_headers do
     api_key = Application.get_env(:sendgrid, :api_key)
     %{
       "Content-Type" => "application/json",
       "Authorization" => "Bearer #{api_key}"
     }
  end

  # Override the base headers with any passed in.
  defp process_request_headers(request_headers) do
    headers =
      request_headers
      |> Enum.into(%{})

    Map.merge(base_headers, headers)
    |> Enum.into([])
  end

end