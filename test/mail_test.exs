defmodule SendGrid.MailTest do
  use ExUnit.Case
  alias SendGrid.{Email, Mail}

  @tag integration: true
  test "send" do
    result =
      Email.build()
      |> Email.add_to(Application.get_env(:sendgrid, :test_address))
      |> Email.put_from(Application.get_env(:sendgrid, :test_address))
      |> Email.put_subject("Test")
      |> Email.put_text("123")
      |> Email.put_html("<p>123</p>")
      |> Email.add_header("TEST", "FOO")
      |> Mail.send()

    assert :ok == result
  end
end
