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
    SendGrid.get(@base_api_url)
    |> case do
      { :ok, %{ status_code: 200, body: body } } -> body["lists"]
      _ -> :error
    end
  end

  @doc """
  Adds a recipient to an email list.

      :ok = add_recipient(123, "recipient_id")
  """
  @spec add_recipient(integer, String.t) :: :ok | :error
  def add_recipient(list_id, recipient_id) do
    SendGrid.post(@base_api_url <> "/#{list_id}/recipients/#{recipient_id}", %{})
    |> case do
      { :ok, %{ status_code: 201 } } -> :ok
      _ -> :error
    end
  end
end