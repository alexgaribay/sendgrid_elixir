defmodule SendGrid.Contacts do
  @base_api_url "/v3/marketing/contacts"

  @doc """
  Finds a contact in the Marketing Campaigns list.

  An email address is provided and an id is returned when found, nil when not found.

  ## Options

  * `:api_key` - API key to use with the request.
  """
  @spec find(String.t(), [SendGrid.api_key()]) ::
          {:ok, map | nil} | {:error, [String.t(), ...]}
  def find(email, opts \\ []) when is_list(opts) do
    with {:ok, response} <-
           SendGrid.post(@base_api_url <> "/search", %{"query" => "email LIKE '#{email}'"}, opts) do
      handle_find_contact_result(response)
    end
  end

  # Handles the result when it's valid and contact is found.
  defp handle_find_contact_result(%{status: 200, body: %{"result" => [%{"id" => _} = result]}}) do
    {:ok, result}
  end

  # Handles the result when it's valid and no contact is found.
  defp handle_find_contact_result(%{status: 200, body: %{}}) do
    {:ok, nil}
  end

  # Handles the result when errors are present.
  defp handle_find_contact_result(%{body: %{} = body}) do
    errors = Enum.map(body["errors"], & &1["message"])

    {:error, errors}
  end

  @doc """
  Deletes a contact in the Marketing Campaigns list.

  A SendGrid marketing campaign id is expected.

  ## Options

  * `:api_key` - API key to use with the request.
  """
  @spec delete(String.t(), [SendGrid.api_key()]) :: :ok | {:error, [String.t(), ...]}
  def delete(id, opts \\ []) when is_list(opts) do
    with {:ok, response} <- SendGrid.delete("#{@base_api_url}?ids=#{id}", opts) do
      handle_delete_result(response)
    end
  end

  # Handles the result when delete is queued
  defp handle_delete_result(%{status: 202}) do
    :ok
  end

  # Handles the result when errors are present.
  defp handle_delete_result(%{body: %{} = body}) do
    errors = Enum.map(body["errors"], & &1["message"])

    {:error, errors}
  end

  @doc """
  Create or update a contact in the contacts list available in Marketing Campaigns.

  ## Options

  * `:api_key` - API key to use with the request.
  """
  @spec upsert(map, [SendGrid.api_key()]) :: :ok | {:error, [String.t(), ...]}
  def upsert(body, opts \\ []) when is_list(opts) do
    with {:ok, response} <- SendGrid.put(@base_api_url, body, opts) do
      handle_upsert_contact_result(response)
    end
  end

  # Handles the result when delete is queued
  defp handle_upsert_contact_result(%{status: 202}) do
    :ok
  end

  # Handles the result when errors are present.
  defp handle_upsert_contact_result(%{body: %{} = body}) do
    errors = Enum.map(body["errors"], & &1["message"])

    {:error, errors}
  end
end
