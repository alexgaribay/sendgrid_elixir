defmodule SendGrid.Contacts.Lists do
  @moduledoc """
  Module to interact with modifying email lists.

  See SendGrid's [Contact API Docs](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html)
  for more detail.
  """

  @base_api_url "/v3/contactdb/lists"

  @doc """
  Retrieves all email lists.

  ## Options

  * `:api_key` - API key to use with the request.
  """
  @spec all([SendGrid.api_key()]) :: {:ok[map()]} | {:error, any()}
  def all(opts \\ []) when is_list(opts) do
    with {:ok, %{status: 200, body: %{"lists" => lists}}} <- SendGrid.get(@base_api_url, opts) do
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
  Adds a recipient to an email list.

  ## Options

  * `:api_key` - API key to use with the request.
  """
  @spec add_recipient(integer(), String.t(), [SendGrid.api_key()]) :: :ok | {:error, any()}
  def add_recipient(list_id, recipient_id, opts \\ []) when is_list(opts) do
    url = "#{@base_api_url}/#{list_id}/recipients/#{recipient_id}"

    with {:ok, %{status: 201}} <- SendGrid.post(url, %{}, opts) do
      :ok
    end
  end

  @doc """
  Deletes a recipient from an email list.

  ## Options

  * `:api_key` - API key to use with the request.
  """
  @spec delete_recipient(integer, String.t(), [SendGrid.api_key()]) :: :ok | {:error, any()}
  def delete_recipient(list_id, recipient_id, opts \\ []) when is_list(opts) do
    url = "#{@base_api_url}/#{list_id}/recipients/#{recipient_id}"

    with {:ok, %{status: 204}} <- SendGrid.delete(url, opts) do
      :ok
    end
  end
end
