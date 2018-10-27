defmodule SendGrid.Contacts.Recipient do
  @moduledoc """
  Struct to help with creating a recipient.
  """

  alias SendGrid.Contacts.Recipient

  @enforce_keys [:email]
  defstruct [:custom_fields, :email]

  @type t :: %Recipient{
          email: String.t(),
          custom_fields: nil | map()
        }

  @doc """
  Builds a Repient to be used in `SendGrid.Contacts.Recipents`.
  """
  @spec build(String.t(), map()) :: t()
  def build(email, custom_fields \\ %{}) when is_map(custom_fields) do
    %Recipient{
      email: email,
      custom_fields: custom_fields
    }
  end

  defimpl Jason.Encoder do
    def encode(%Recipient{email: email, custom_fields: fields}, opts) when is_map(fields) do
      Jason.Encode.map(Map.merge(fields, %{email: email}), opts)
    end

    def encode(%Recipient{email: email, custom_fields: nil}, opts) do
      Jason.Encode.map(%{email: email}, opts)
    end
  end
end
