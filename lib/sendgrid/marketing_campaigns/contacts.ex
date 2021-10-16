defmodule SendGrid.Marketing.Contacts do
  @moduledoc """
  Module to interact with contacts.

  See SendGrid's [Contact API Docs](https://sendgrid.api-docs.io/v3.0/contacts)
  for more detail.
  """

  @base_api_url "/v3/marketing/contacts"

  @doc """
  Adds one or multiple contacts to one or multiple lists available in Marketing Campaigns.

  When adding a contact, an email address must be provided at a minimum.
  The process is asynchrnous and SendGrid will return a Job ID to check the status.

  ## Options

  * `:api_key` - API key to use with the request.

  ## Examples

      {:ok, recipient_id} = add(["111-222-333"], [%{email: "test@example.com", first_name: "Test"}])
  """
  @spec add(list(String.t()), list(), [SendGrid.api_key()]) ::
          {:ok, String.t()} | {:error, [String.t(), ...]}
  def add(list_ids, contacts, opts \\ []) when is_list(opts) do
    data = %{list_ids: list_ids, contacts: contacts}

    with {:ok, response} <- SendGrid.put(@base_api_url, data, opts) do
      handle_result(response)
    end
  end

  @doc """
  Deletes a contact.
  The process is asynchrnous and SendGrid will return a Job ID to check the status.

  ## Options

  * `:api_key` - API key to use with the request.
  """
  @spec delete(list(), [SendGrid.api_key()]) :: {:ok, String.t()} | {:error, any()}
  def delete(contact_ids, opts \\ []) when is_list(opts) do
    ids = Enum.join(contact_ids, ",")
    url = "#{@base_api_url}?ids=#{ids}"

    with {:ok, response} <- SendGrid.delete(url, opts) do
      handle_result(response)
    end
  end

  @doc """
  Deletes all contacts.
  The process is asynchrnous and SendGrid will return a Job ID to check the status.

  ## Options

  * `:api_key` - API key to use with the request.
  """
  @spec delete_all([SendGrid.api_key()]) :: {:ok, String.t()} | {:error, any()}
  def delete_all(opts \\ []) when is_list(opts) do
    url = "#{@base_api_url}?delete_all_contacts=true"

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
