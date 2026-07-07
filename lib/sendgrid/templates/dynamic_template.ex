defmodule SendGrid.DynamicTemplate do
  @moduledoc """
    Module to interact with transaction email templates.
  """
  alias __MODULE__


  @derive Jason.Encoder
  defstruct [
    id: nil,
    name: nil,
    updated_at: nil,
    generation: nil,
    versions: nil
  ]

  @type t :: %DynamicTemplate{
    id: String.t,
    name: String.t,
    updated_at: DateTime.t | nil,
    versions: [Versions.t]
  }

  @spec new(Map.t, :json) :: Template.t
  def new(json, :json) do
    # versions.
    versions = case json["versions"] do
      nil -> []
      versions when is_list(versions) ->
        for version <- versions do
          SendGrid.Template.Version.new(version, :json)
        end
    end

    %DynamicTemplate{
      id: json["id"],
      name: json["name"],
      updated_at: reformat_sendgrid_date(json["updated_at"]),
      versions: versions
    }
  end

  defp reformat_sendgrid_date(date = %DateTime{}), do: date
  defp reformat_sendgrid_date(date) when is_bitstring(date) do
    [a,b] = String.split(date)
    case DateTime.from_iso8601("#{a} #{b}.0Z") do
      {:ok, d, _} -> d
      _ -> nil
    end
  end
  defp reformat_sendgrid_date(_), do: nil


  defimpl Jason.Encoder do
    def encode(%SendGrid.DynamicTemplate{} = template, opts) do
      raw = template
            |> Map.from_struct()
            |> Map.drop([:updated_at])
            |> Enum.filter(fn({_k,v}) -> v != nil end)
            |> Map.new()
            |> Map.put(:generation, :dynamic)
      Jason.Encode.map(raw, opts)
    end
  end

end
