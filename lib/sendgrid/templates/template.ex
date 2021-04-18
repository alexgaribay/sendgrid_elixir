defmodule SendGrid.Template do
  @moduledoc """
    Module to interact with transaction email templates.
  """
  alias __MODULE__

  @generations %{
    "dynamic" => :dynamic,
    "legacy" => :legacy,
  }

  @derive Jason.Encoder
  defstruct [
    id: nil,
    name: nil,
    updated_at: nil,
    generation: nil,
    versions: nil
  ]

  @type t :: %Template{
    id: String.t,
    name: String.t,
    updated_at: DateTime.t | nil,
    generation: :dynamic | :legacy | String.t,
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

    %Template{
      id: json["id"],
      name: json["name"],
      updated_at: reformat_sendgrid_date(json["updated_at"]),
      generation: @generations[json["generation"]] || json["generation"],
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

end
