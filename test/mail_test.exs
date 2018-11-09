defmodule SendGrid.MailTest do
  use ExUnit.Case
  alias SendGrid.{Email, Mail}

  @moduletag integration: true

  describe "send" do
    test "with an Email containing no personalization" do
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

    test "with an Email containing multiple personalizations" do
      base =
        Email.build()
        |> Email.put_from(Application.get_env(:sendgrid, :test_address))
        |> Email.put_subject("Test")
        |> Email.put_text("123")
        |> Email.put_html("<p>123</p>")

      email =
        Enum.reduce(1..5, base, fn x, email ->
          personalization =
            Email.build()
            |> Email.add_to(Application.get_env(:sendgrid, :test_address))
            |> Email.put_subject("Test #{x}")
            |> Email.add_header("TEST#{x}", "FOO")
            |> Email.to_personalization()

          Email.add_personalization(email, personalization)
        end)

      assert :ok == Mail.send(email)
    end
  end
end
