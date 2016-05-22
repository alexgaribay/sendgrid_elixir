defmodule SendGrid.Mailer do
  @moduledoc """
  Module to send transactional email.
  """

  alias SendGrid.Email

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
      |> format_email_data
      |> convert_to_form_data

    case SendGrid.post("/api/mail.send.json", payload, [{ "Content-Type", "application/x-www-form-urlencoded" }]) do
      { :ok, %{ status_code: 200 } } -> :ok
      { :ok, %{ body: body } } -> { :error, body["errors"] }
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end

  defp format_email_data(%Email{} = email) do
    from_name = email.from_name
    reply_to = email.reply_to
    x_smtpapi =
      email
      |> full_x_smtpapi
      |> Poison.encode!

    email
    |> Map.drop([:from_name, :x_smtpapi, :reply_to, :sub])
    |> Map.put(:fromname, from_name)
    |> Map.put(:replyto, reply_to)
    |> Map.put("x-smtpapi", x_smtpapi)
  end

  defp full_x_smtpapi(%Email{x_smtpapi: in_smtpapi, sub: nil}), do: in_smtpapi
  defp full_x_smtpapi(%Email{x_smtpapi: in_smtpapi, sub: sub}), do: Map.put(in_smtpapi, :sub, sub)

  defp convert_to_form_data(email) do
    email
    |> Map.from_struct
    |> Map.to_list
    |> Enum.filter_map(fn({ _k, v }) -> v != nil && v != "null" end, fn({ k, v }) -> encode_attribute(k, v) end)
    |> Enum.join("&")
  end

  defp encode_attribute(key, list) when is_list(list) do
    Enum.map(list, fn (item) -> "#{ key }[]=#{ URI.encode_www_form(item) }" end)
    |> Enum.join("&")
  end

  defp encode_attribute("x-smtpapi", value), do: "x-smtpapi=#{value}"
  defp encode_attribute(key, value), do: "#{ key }=#{ URI.encode_www_form(value) }"
end
