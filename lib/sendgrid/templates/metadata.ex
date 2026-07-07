defmodule SendGrid.MetaData do
  @moduledoc """
    Pagination Meta Details,
  """

  defstruct [
    self: nil,
    next: nil,
    count: nil,
    options: nil,
  ]

  @type t :: %SendGrid.MetaData{
               self: String.t | nil,
               next: String.t | nil,
               count: integer,
               options: SendGrid.query(),
             }

  @spec new(Map.t, SendGrid.query(), :json) :: SendGrid.MetaData.t | {:error, [String.t]} | {:error, String.t}
  def new(json, options, :json) do
    %__MODULE__{
      count: json["count"],
      self: extract_page_token(json["self"]),
      next: extract_page_token(json["next"]),
      options: options
    }
  end

  defp extract_page_token(url) when is_bitstring(url) do
    case Regex.run(~r/.*page_token=([^&]+)/, url) do
      [_, m] -> m
      _ -> nil
    end
  end
  defp extract_page_token(_), do: nil

end