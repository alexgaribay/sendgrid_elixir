defmodule SendGrid.Contacts.Recipients do
  @moduledoc """
  Module to interact with modifying contacts.

  See [SendGrid's Contact API Docs](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html)
  for more detail.
  """

  @base_api_url "/v3/contactdb/recipients"

  @doc """
  Adds a contact to the contacts list available in Marketing Campaigns. At a minimum, an email address must provided.
  Additionaly, custom fields that have already been created can added as well.

      {:ok, recipient_id} = add("test@example.com", %{"name" => "John Doe"})

      {:ok, recipient_id} = add("test@example.com")
  """
  @spec add(String.t(), %{}) :: :ok | {:error, list(String.t())}
  def add(email_address, custom_fields \\ %{}) do
    payload = Map.merge(%{"email" => email_address}, custom_fields)

    SendGrid.post(@base_api_url, [payload])
    |> handle_recipient_result
  end

  # Handles the result when errors are present.
  defp handle_recipient_result({:ok, %{body: body = %{"error_count" => count}}}) when count > 0 do
    errors =
      body["errors"]
      |> Enum.map(fn error -> error["message"] end)

    {:error, errors}
  end

  # Handles the result when it's valid.
  defp handle_recipient_result({:ok, %{body: body}}) do
    [recipient_id] = body["persisted_recipients"]
    {:ok, recipient_id}
  end
end
