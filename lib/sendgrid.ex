defmodule SendGrid do
  @moduledoc """
  Interface to SendGrid's API.
  
  ## Configuration

  A configuration key is expected with a working SendGrid API key.

      config :sendgrid,
        api_key: "sendgrid_api_key"

  ## Usage

  Most usage with this library will be with composing transactional emails. Refer to `SendGrid.Email` for full 
  documentation and usage.
  
  """

  use HTTPoison.Base

  @api_url "https://api.sendgrid.com"

  defp process_url(url) do
    @api_url <> url
  end

  defp api_key() do
    Application.get_env(:sendgrid, :api_key)
  end

  # Default headers to be sent.
  defp base_headers() do
     %{
       "Content-Type" => "application/json",
       "Authorization" => "Bearer #{api_key()}"
     }
  end

  defp process_request_body(body) when is_binary(body), do: body
  defp process_request_body(body), do: Poison.encode!(body)

  # Override the base headers with any passed in.
  defp process_request_headers(request_headers) do
    headers =
      request_headers
      |> Enum.into(%{})

    Map.merge(base_headers(), headers)
    |> Enum.into([])
  end

  defp process_response_body(body) do
    case Poison.decode(body) do
      { :ok, data } -> data
      _ -> body
    end
  end

end
