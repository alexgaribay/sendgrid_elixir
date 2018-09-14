defmodule SendGrid.MailerTest do
  use ExUnit.Case
  alias SendGrid.{Email, Mailer}

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
      |> SendGrid.Mailer.send()

    assert :ok == result
  end

  describe "format_payload" do
    test "removes nil/emply personalizations" do
      assert Mailer.format_payload(Email.build()) ==
               %{
                 attachments: nil,
                 content: nil,
                 from: nil,
                 headers: %{},
                 mail_settings: %{sandbox_mode: %{enable: false}},
                 personalizations: [%{}],
                 reply_to: nil,
                 send_at: nil,
                 subject: nil,
                 template_id: nil
               }
    end

    test "includes custom header" do
      email = Email.build() |> Email.add_header("TEST", "FOO")
      assert %{headers: %{"TEST" => "FOO"}} = Mailer.format_payload(email)
    end
  end
end
