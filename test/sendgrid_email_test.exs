defmodule SendGrid.Email.Test do
  use ExUnit.Case, async: true
  doctest SendGrid.Email, import: true

  alias SendGrid.Email

  @email "test@email.com"
  @name "John Doe"

  test "build/0" do
    assert Email.build() == %Email{}
  end

  test "add_to/2" do
    email = Email.add_to(Email.build(), @email)
    assert email.to == [%{ email: @email }]
  end

  test "add_to/3" do
    email = Email.add_to(Email.build(), @email, @name)
    assert email.to == [%{ email: @email, name: @name }]
  end

  test "add_to with multiple addresses" do
    email =
      Email.build()
      |> Email.add_to(@email)
      |> Email.add_to(@email, @name)

    assert email.to == [%{ email: @email }, %{ email: @email, name: @name }]
  end

  test "put_from/2" do
    email = Email.put_from(Email.build(), @email)
    assert email.from == %{ email: @email }
  end

  test "put_from/3" do
    email = Email.put_from(Email.build(), @email, @name)
    assert email.from == %{ email: @email, name: @name }
  end

  test "add_cc/2" do
    email = Email.add_cc(Email.build(), @email)
    assert email.cc == [%{ email: @email }]
  end

  test "add_cc/3" do
    email = Email.add_cc(Email.build(), @email, @name)
    assert email.cc == [%{ email: @email, name: @name }]
  end

  test "add_cc with multiple addresses" do
    email =
      Email.build()
      |> Email.add_cc(@email)
      |> Email.add_cc(@email, @name)

    assert email.cc == [%{ email: @email }, %{ email: @email, name: @name }]
  end

  test "add_bcc/2" do
    email = Email.add_bcc(Email.build(), @email)
    assert email.bcc == [%{ email: @email }]
  end

  test "add_bcc/3" do
    email = Email.add_bcc(Email.build(), @email, @name)
    assert email.bcc == [%{ email: @email, name: @name }]
  end

  test "add_bcc with multiple addresses" do
    email =
      Email.build()
      |> Email.add_bcc(@email)
      |> Email.add_bcc(@email, @name)

    assert email.bcc == [%{ email: @email }, %{ email: @email, name: @name }]
  end

  test "put_reply_to/2" do
    email = Email.put_reply_to(Email.build(), @email)
    assert email.reply_to == %{ email: @email }
  end

  test "put_reply_to/3" do
    email = Email.put_reply_to(Email.build(), @email, @name)
    assert email.reply_to == %{ email: @email, name: @name}
  end

  test "put_subject/2" do
    subject = "Test Subject"
    email = Email.put_subject(Email.build(), subject)
    assert email.subject == subject
  end

  test "put_text/2" do
    text = "Some Text"
    email = Email.put_text(Email.build(), text)
    assert email.content == [%{ type: "text/plain", value: text }]
  end

  test "put_html/2" do
    html = "<p>Some Text</p>"
    email = Email.put_html(Email.build(), html)
    assert email.content == [%{ type: "text/html", value: html }]
  end

  test "put multiple content types" do
    text = "Some Text"
    html = "<p>Some Text</p>"
    email =
      Email.build()
      |> Email.put_text(text)
      |> Email.put_html(html)
    assert email.content == [%{ type: "text/plain", value: text }, %{ type: "text/html", value: html }]
  end

  test "text content comes before html" do
    text = "Some Text"
    html = "<p>Some Text</p>"
    email =
      Email.build()
      |> Email.put_html(html)
      |> Email.put_text(text)
    assert email.content == [%{ type: "text/plain", value: text }, %{ type: "text/html", value: html }]
  end

  test "put_template/2" do
    template_id = "some_unique_id"
    email = Email.put_template(Email.build(), template_id)
    assert email.template_id == template_id
  end

  test "add_substitution/3" do
    email = Email.add_substitution(Email.build(), "-someValue-", "Cool")
    assert email.substitutions == %{ "-someValue-" => "Cool" }
  end

  test "add_subtitution/3 x2" do
    email = Email.add_substitution(Email.build(), "-someValue-", "Cool")
      |> Email.add_substitution("-newValue-", "Panda")
    assert email.substitutions == %{ "-someValue-" => "Cool", "-newValue-" => "Panda" }
  end

  test "put_send_at/2" do
    time = 123456789
    email = Email.put_send_at(Email.build(), time)
    assert email.send_at == time
  end

  test "email" do
    :ok = Email.build()
    |> Email.add_to(@email)
    |> Email.put_from(@email)
    |> Email.put_subject("Test")
    |> Email.put_text("123")
    |> Email.put_html("<p>123</p>")
    |> SendGrid.Mailer.send()
  end

end