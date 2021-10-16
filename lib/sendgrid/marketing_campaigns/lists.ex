defmodule SendGrid.Marketing.Lists do
  @moduledoc """
  Module to interact with modifying email lists.

  See SendGrid's [Contact API Docs](https://sendgrid.api-docs.io/v3.0/lists)
  for more detail.
  """

  @base_api_url "/v3/marketing/lists"

  @doc """
  Retrieves all email lists.

  ## Options

  * `:api_key` - API key to use with the request.
  """
  @spec all([SendGrid.api_key()]) :: {:ok, [map()]} | {:error, any()}
  def all(opts \\ []) when is_list(opts) do
    with {:ok, %{status: 200, body: %{"result" => lists}}} <- SendGrid.get(@base_api_url, opts) do
      {:ok, lists}
    end
  end

  @doc """
  Creates an email list.

  ## Options

  * `:api_key` - API key to use with the request.
  """
  @spec add(String.t(), [SendGrid.api_key()]) :: {:ok, map()} | {:error, :any}
  def add(list_name, opts \\ []) when is_list(opts) do
    with {:ok, %{status: 201, body: body}} <-
           SendGrid.post(@base_api_url, %{name: list_name}, opts) do
      {:ok, body}
    end
  end

  @doc """
  Retrieves all recipients from an email list.

  ## Options

  * `:api_key` - API key to use with the request.
  * `:page` - Page to start at. **Defaults to 1**.
  * `:page_size` - Page size for pagination. **Defaults to 100**.
  """
  @spec all_recipients(integer(), [SendGrid.api_key() | SendGrid.page() | SendGrid.page_size()]) ::
          {:ok[map()]} | {:error, any()}
  def all_recipients(list_id, opts \\ []) when is_list(opts) do
    page = Keyword.get(opts, :page, 1)
    page_size = Keyword.get(opts, :page_size, 100)
    query = [page: page, page_size: page_size]

    request_opts =
      opts
      |> Keyword.drop([:page, :page_size])
      |> Keyword.merge(query: query)

    url = "#{@base_api_url}/#{list_id}/recipients"

    with {:ok, %{status: 200, body: %{"recipients" => recipients}}} <-
           SendGrid.get(url, request_opts) do
      {:ok, recipients}
    end
  end

  @doc """
  Removes a contact from a list.

  ## Options

  * `:api_key` - API key to use with the request.
  """
  @spec remove_contact(list(String.t()), list(String.t())[SendGrid.api_key()]) ::
          {:ok, String.t()} | {:error, any()}
  def remove_contact(list_id, contact_ids, opts \\ []) when is_list(opts) do
    ids = Enum.join(contact_ids, ",")
    url = "#{@base_api_url}/#{list_id}/contacts?contact_ids=#{ids}"

    with {:ok, response} <- SendGrid.delete(url, opts) do
      handle_result(response)
    end
  end

  # Handles the result when it's valid.
  defp handle_result(%{body: %{"job_id" => job_id}}) do
    {:ok, job_id}
  end

  # Handles the result when errors are present.
  defp handle_result(%{body: %{"error_count" => count} = body}) when count > 0 do
    errors = Enum.map(body["errors"], & &1["message"])
    {:error, errors}
  end

  defp handle_result(data), do: {:error, data}
end
