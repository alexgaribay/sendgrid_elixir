defmodule SendGrid.Personalization do
  @moduledoc """
  Personalizations are used by SendGrid v3 API to identify who should receive
  the email as well as specifics about how you would like the email to be handled.
  """

  alias SendGrid.{Email, Personalization}

  defstruct to: nil,
            cc: nil,
            bcc: nil,
            subject: nil,
            substitutions: nil,
            custom_args: nil,
            dynamic_template_data: nil,
            send_at: nil,
            headers: nil

  @type t :: %Personalization{
          to: nil | [Email.recipient()],
          cc: nil | [Email.recipient()],
          bcc: nil | [Email.recipient()],
          subject: nil | String.t(),
          substitutions: nil | Email.substitutions(),
          custom_args: nil | Email.custom_args(),
          dynamic_template_data: nil | Email.dynamic_template_data(),
          send_at: nil | non_neg_integer(),
          headers: nil | Email.headers()
        }

  defimpl Jason.Encoder do
    def encode(%Personalization{} = personalization, opts) do
      params =
        personalization
        |> Map.take(
          ~w(to cc bcc subject substitutions custom_args dynamic_template_data send_at headers)a
        )
        |> Enum.filter(fn {_key, v} -> v != nil && v != [] end)
        |> Enum.into(%{})

      Jason.Encode.map(params, opts)
    end
  end
end
