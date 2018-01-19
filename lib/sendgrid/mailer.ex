defmodule SendGrid.Mailer do
  @moduledoc """
  Module for sending transactional email.

  ## Sandbox Mode

  Sandbox mode allows you to test sending emails without actually delivering emails and using your email quota.

  To send emails in sandbox mode, ensure the config key is set:

      config :sendgrid,
        api_key: "SENDGRID_API_KEY",
        sandbox_enable: true

  """

  alias SendGrid.Email

  @mail_url "/v3/mail/send"

  @doc """
  Sends the built email.

  ## Examples

      email =
        Email.build()
        |> Email.add_to("test@email.com")
        |> Email.put_from("test2@email.com")
        |> Email.put_subject("Hello from Elixir")
        |> Email.put_text("Sent with Elixir")

      :ok = Mailer.send(email)
  """
  @spec send(SendGrid.Email.t()) :: :ok | {:error, [String.t()]} | {:error, String.t()}
  def send(%Email{} = email) do
    payload = format_payload(email)

    case SendGrid.post(@mail_url, payload, [{"Content-Type", "application/json"}]) do
      {:ok, %{status_code: status_code}} when status_code in [200, 202] -> :ok
      {:ok, %{body: body}} -> {:error, body["errors"]}
      _ -> {:error, "Unable to communicate with SendGrid API."}
    end
  end

  @doc false
  def format_payload(%Email{} = email) do
    personalizations =
      email
      |> Map.take(~w(to cc bcc substitutions custom_args)a)
      |> Stream.filter(fn {_key, v} -> v != nil && v != [] end)
      |> Enum.into(%{})

    headers =
      email.headers
      |> List.wrap()
      |> Enum.into(%{})

    %{
      personalizations: [personalizations],
      from: email.from,
      subject: email.subject,
      content: email.content,
      reply_to: email.reply_to,
      send_at: email.send_at,
      template_id: email.template_id,
      attachments: email.attachments,
      headers: headers,
      mail_settings: %{sandbox_mode: %{enable: sandbox_mode()}}
    }
  end

  defp sandbox_mode(), do: Application.get_env(:sendgrid, :sandbox_enable) || false
end
