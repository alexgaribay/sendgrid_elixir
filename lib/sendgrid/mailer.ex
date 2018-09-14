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

  alias SendGrid.{Email, Personalization}

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
    %Email{
      to: to,
      from: from,
      subject: subject,
      content: content,
      reply_to: reply_to,
      send_at: send_at,
      template_id: template_id,
      headers: headers,
      attachments: attachments,
      personalizations: personalizations
    } = email

    personalizations =
      personalizations
      |> Enum.map(&to_payload/1)
      |> Enum.reject(fn p -> p == %{} end)
      |> Enum.reverse()

    personalizations =
      case to do
        nil ->
          personalizations

        _to ->
          email_personalization =
            email
            |> Map.take(~w(to cc bcc substitutions custom_args)a)
            |> sanitize_personalization()

          [email_personalization | personalizations]
      end

    headers = headers_to_payload(headers)

    %{
      personalizations: personalizations,
      from: from,
      subject: subject,
      content: content,
      reply_to: reply_to,
      send_at: send_at,
      template_id: template_id,
      attachments: attachments,
      headers: headers,
      mail_settings: %{sandbox_mode: %{enable: sandbox_mode()}}
    }
  end

  defp to_payload(%Personalization{} = personalization) do
    payload =
      personalization
      |> Map.from_struct()
      |> Map.take(~w(to cc bcc subject substitutions custom_args send_at headers)a)
      |> sanitize_personalization()

    case Map.get(payload, :headers) do
      nil ->
        payload

      headers ->
        headers = headers_to_payload(headers)

        Map.put(payload, :headers, headers)
    end
  end

  defp sanitize_personalization(attrs) do
    attrs
    |> Stream.filter(fn {_key, v} -> v != nil && v != [] end)
    |> Enum.into(%{})
  end

  defp headers_to_payload(headers) do
    headers
    |> List.wrap()
    |> Enum.into(%{})
  end

  defp sandbox_mode(), do: Application.get_env(:sendgrid, :sandbox_enable) || false
end
