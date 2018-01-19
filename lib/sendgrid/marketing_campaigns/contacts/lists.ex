defmodule SendGrid.Contacts.Lists do
  @moduledoc """
  Module to interact with modifying email lists.

  See [SendGrid's Contact API Docs](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html)
  for more detail.
  """

  @base_api_url "/v3/contactdb/lists"

  @doc """
  Retrieves all email lists.
  """
  @spec all() :: list(%{}) | :error
  def all() do
    case SendGrid.get(@base_api_url) do
      {:ok, %{status_code: 200, body: body}} -> body["lists"]
      _ -> :error
    end
  end

  @doc """
  Creates an email list.

      {:ok, 2} = add("marketing")

  """
  @spec add(String.t()) :: {:ok, integer} | :error
  def add(list_name) do
    case SendGrid.post(@base_api_url, %{name: list_name}) do
      {:ok, %{status_code: 201, body: body}} -> {:ok, body["id"]}
      _ -> :error
    end
  end

  @doc """
  Retrieves all recipients from an email list.
  """
  @spec all_recipients(integer, integer, integer) :: list(%{}) | :error
  def all_recipients(list_id, page \\ 1, page_size \\ 100) do
    url = @base_api_url <> "/#{list_id}/recipients?page_size=#{page_size}&page=#{page}"

    case SendGrid.get(url) do
      {:ok, %{status_code: 200, body: body}} -> body["recipients"]
      _ -> :error
    end
  end

  @doc """
  Adds a recipient to an email list.

      :ok = add_recipient(123, "recipient_id")

  """
  @spec add_recipient(integer, String.t()) :: :ok | :error
  def add_recipient(list_id, recipient_id) do
    url = @base_api_url <> "/#{list_id}/recipients/#{recipient_id}"

    case SendGrid.post(url, %{}) do
      {:ok, %{status_code: 201}} -> :ok
      _ -> :error
    end
  end

  @doc """
  Deletes a recipient from an email list.

      :ok = delete_recipient(123, "recipient_id")

  """
  @spec delete_recipient(integer, String.t()) :: :ok | :error
  def delete_recipient(list_id, recipient_id) do
    url = @base_api_url <> "/#{list_id}/recipients/#{recipient_id}"

    case SendGrid.delete(url, %{}) do
      {:ok, %{status_code: 204}} -> :ok
      _ -> :error
    end
  end
end
