defmodule SendGrid.Mailer do
  @moduledoc """
  Module to send transactional email.

  To send emails in sandbox mode, ensure the config key is set:
  ```elixir
      config :sendgrid,
        api_key: "SENDGRID_API_KEY",
        sandbox_enable: true
  ```
  """

  alias SendGrid.Email

  @mail_url "/v3/mail/send"
  @sandbox_mode Application.get_env(:sendgrid, :sandbox_enable) || false


  @doc """
  Sends the built email.

      email =
        Email.build()
        |> Email.put_to("test@email.com")
        |> Email.put_from("test2@email.com")
        |> Email.put_subject("Hello from Elixir")
        |> Email.put_text("Sent with Elixir")

      :ok = Mailer.send(email)

  """
  @spec send(SendGrid.Email.t) :: :ok | { :error, list(String.t) } | { :error, String.t }
  def send(%Email{} = email) do
    payload =
      email
      |> format_email_for_sending

    case SendGrid.post(@mail_url, payload, [{ "Content-Type", "application/json" }]) do
      { :ok, %{ status_code: 202 } } -> :ok
      { :ok, %{ body: body } } -> { :error, body["errors"] }
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end

  defp format_email_for_sending(%Email{} = email) do
    personalizations =
      email
      |> Map.take([:to, :cc, :bcc, :substitutions])
      |> Stream.into([])
      |> Stream.filter(fn { _key, v } -> v != nil && v != [] end)
      |> Enum.into(%{})

    %{
      personalizations: [personalizations],
      from: email.from,
      subject: email.subject,
      content: email.content,
      reply_to: email.reply_to,
      send_at: email.send_at,
      mail_settings: %{ sandbox_mode: %{ enable: @sandbox_mode } }
    }
  end
end
