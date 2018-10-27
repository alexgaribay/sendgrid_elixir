defmodule SendGrid.Mail do
  @moduledoc """
  Module for sending transactional email.

  ## Sandbox Mode

  Sandbox mode allows you to test sending emails without actually delivering emails and using your email quota.

  To send emails in sandbox mode, ensure the config key is set:

      config :sendgrid,
        api_key: "SENDGRID_API_KEY",
        sandbox_enable: true

  Optionally, you can use `SendGrid.Email.set_sandbox/2` to configure it per email.
  """

  alias SendGrid.Email

  @mail_url "/v3/mail/send"

  @doc """
  Sends the built email.

  ## Options

  * `:api_key` - API key to use with the request.

  ## Examples

      email =
        Email.build()
        |> Email.add_to("test@email.com")
        |> Email.put_from("test2@email.com")
        |> Email.put_subject("Hello from Elixir")
        |> Email.put_text("Sent with Elixir")

      :ok = Mail.send(email)
  """
  @spec send(SendGrid.Email.t(), [SendGrid.api_key()]) ::
          :ok | {:error, [String.t()]} | {:error, String.t()}
  def send(%Email{} = email, opts \\ []) when is_list(opts) do
    case SendGrid.post(@mail_url, email, opts) do
      {:ok, %{status: status}} when status in [200, 202] -> :ok
      {:ok, %{body: body}} -> {:error, body["errors"]}
      _ -> {:error, "Unable to communicate with SendGrid API."}
    end
  end
end
