defmodule SendGrid.Template.Version do
  @moduledoc """
    Module to interact with transaction email template versions.
  """
  alias __MODULE__

  @derive Jason.Encoder
  defstruct [
    id: nil,
    template_id: nil,
    active: nil,
    name: nil,
    html_content: "",
    plain_content: "",
    subject: "",
    updated_at: nil
  ]

  @type t :: %Version{
    id: String.t,
    template_id: String.t,
    active: nil,
    name: String.t,
    html_content: String.t,
    plain_content: String.t,
    subject: String.t,
    updated_at: String.t # Should be converted to unix epoch or Timex
  }

  @spec new(Map.t, :json) :: Version.t
  def new(json, :json) do
    %Version{
      id: json["id"],
      template_id: json["template_id"],
      active: json["active"] == 1,
      name: json["name"],
      subject: json["subject"],
      updated_at: json["updated_at"],

      # content only returned when specifically fetching entry by id. Will be null otherwise.
      html_content: json["html_content"],
      plain_content: json["plain_content"]
    }
  end
end
