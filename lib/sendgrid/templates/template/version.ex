defmodule SendGrid.Template.Version do
  @moduledoc """
    Module to interact with transaction email template versions.
  """
  alias __MODULE__

  @derive Jason.Encoder
  defstruct [
    id: nil,
    template_id: nil,
    updated_at: nil,
    thumbnail_url: nil,
    warnings: nil,
    active: nil,
    name: nil,

    html_content: "",
    plain_content: "",
    generate_plain_content: nil,
    subject: "",
    editor: nil,
    test_data: nil,
  ]

  @type t :: %Version{
               id: String.t,
               template_id: String.t,
               updated_at: DateTime.t,
               thumbnail_url: String.t,
               warnings: list | nil,
               active: integer | nil,
               name: String.t,

               html_content: String.t,
               plain_content: String.t,
               generate_plain_content: boolean | nil,
               subject: String.t,
               editor: String.t | nil,
               test_data: Map.t | nil,
             }

  @spec new(Map.t, :json) :: Version.t
  def new(json, :json) do
    %Version{
      id: json["id"],
      template_id: json["template_id"],
      updated_at: reformat_sendgrid_date(json["updated_at"]),
      thumbnail_url: json["thumbnail_url"],
      warnings: json["warnings"],
      active: json["active"],
      name: json["name"],
      # content only returned when specifically fetching entry by id. Will be null otherwise.
      html_content: json["html_content"],
      plain_content: json["plain_content"],
      generate_plain_content: json["generate_plain_content"],
      subject: json["subject"],
      editor: json["editor"],
      test_data: json["test_data"]
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
    def encode(%SendGrid.Template.Version{} = version, opts) do
      raw = version
            |> Map.from_struct()
            |> Map.drop([:updated_at, :editor, :thumbnail_url])
            |> Enum.filter(fn({_k,v}) -> v != nil end)
            |> Map.new()
      Jason.Encode.map(raw, opts)
    end
  end


end
