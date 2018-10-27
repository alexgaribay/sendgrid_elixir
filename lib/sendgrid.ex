defmodule SendGrid do
  @moduledoc """
  Interface to SendGrid's API.

  ## Configuration

  An API key can be set in your application's config.

      # Compile-time configured key.
      config :sendgrid,
        api_key: "sendgrid_api_key"

      # Run-time configured key
      config :sendgrid,
        api_key: {:system, "ENV_KEY"}

  Optionally you can supply an API key as a keyword option in the last argument
  of any API call to override and set the API key to use for the request.

      SendGrid.Mail.send(..., api_key: "API_KEY")

  ## Usage

  Most usage with this library will be with composing transactional emails.
  Refer to `SendGrid.Email` for full documentation and usage.
  """

  alias SendGrid.Response

  @type api_key :: {:api_key, String.t()}
  @type query :: {:query, Keyword.t()}
  @type page :: {:page, pos_integer()}
  @type page_size :: {:page_size, pos_integer()}

  @typedoc """
  Optional arguments to use when performing a request.
  """
  @type options :: [query | api_key]

  @doc """
  Performs a GET request.

  ## Options

  * `:api_key` - API key to use with the request.
  * `:query` - Keyword list of query params to use with the request.
  """
  @spec get(path :: String.t(), options :: options()) :: {:ok, Response.t()} | {:error, any()}
  def get(path, opts \\ []) when is_list(opts) do
    opts
    |> api_key()
    |> build_client()
    |> Tesla.get(path, query_opts(opts))
    |> parse_response()
  end

  @doc """
  Performs a POST request.

  ## Options

  * `:api_key` - API key to use with the request.
  * `:query` - Keyword list of query params to use with the request.
  """
  @spec post(path :: String.t(), body :: map(), options :: options()) ::
          {:ok, Response.t()} | {:error, any()}
  def post(path, body, opts \\ []) when is_map(body) and is_list(opts) do
    opts
    |> api_key()
    |> build_client()
    |> Tesla.post(path, body, query_opts(opts))
    |> parse_response()
  end

  @doc """
  Performs a PATCH request.

  ## Options

  * `:api_key` - API key to use with the request.
  * `:query` - Keyword list of query params to use with the request.
  """
  @spec patch(path :: String.t(), body :: map(), options :: options()) ::
          {:ok, Response.t()} | {:error, any()}
  def patch(path, body, opts \\ []) when is_map(body) and is_list(opts) do
    opts
    |> api_key()
    |> build_client()
    |> Tesla.patch(path, body, query_opts(opts))
    |> parse_response()
  end

  @doc """
  Performs a DELETE request.

  ## Options

  * `:api_key` - API key to use with the request.
  * `:query` - Keyword list of query params to use with the request.
  """
  @spec delete(path :: String.t(), options :: options()) :: {:ok, Response.t()} | {:error, any()}
  def delete(path, opts \\ []) when is_list(opts) do
    opts
    |> api_key()
    |> build_client()
    |> Tesla.delete(path, query_opts(opts))
    |> parse_response()
  end

  defp api_key(opts) do
    api_key = Keyword.get(opts, :api_key) || runtime_key()

    unless api_key do
      raise RuntimeError, """
      No API key is configured for SendGrid. Update your config your pass in a
      key with `:api_key` as an addional request option.

          SendGrid.get("/stats", api_key: "API_KEY")

          config :sendgrid,
            api_key: "sendgrid_api_key"

          config :sendgrid,
            api_key: {:system, "SENDGRID_KEY"}
      """
    end

    api_key
  end

  defp runtime_key do
    case Application.get_env(:sendgrid, :api_key) do
      {:system, env_key} -> System.get_env(env_key)
      key -> key
    end
  end

  defp build_client(api_key) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://api.sendgrid.com"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{api_key}"}]}
    ]

    Tesla.client(middleware)
  end

  defp query_opts(opts) do
    Keyword.take(opts, [:query])
  end

  defp parse_response({:ok, %{body: body, headers: headers, status: status}}) do
    {:ok, %Response{body: body, headers: headers, status: status}}
  end

  defp parse_response({:error, _} = error), do: error
end
