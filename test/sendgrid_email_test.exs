defmodule SendGrid.Email.Test do
  use ExUnit.Case, async: true
  doctest SendGrid.Email

  alias SendGrid.Email

  test "build()" do
    assert Email.build() == %Email{}
  end

  test "put_to" do
    email = Email.put_to(Email.build(), "test@email.com")
    assert email.to == "test@email.com"
  end

  test "put_from" do
    email = Email.put_from(Email.build(), "test@email.com")
    assert email.from == "test@email.com"
  end

  test "add_cc single" do
    email = Email.add_cc(Email.build(), "test@email.com")
    assert email.cc == ["test@email.com"]
  end

  test "add_cc multiple" do
    email = Email.add_cc(Email.build(), ["test1@email.com", "test2@email.com"])
    assert email.cc == ["test1@email.com", "test2@email.com"]
  end

  test "delete_cc" do
    email = Email.delete_cc(%Email{ cc: ["test1@email.com", "test2@email.com"] }, "test1@email.com")
    assert email.cc == ["test2@email.com"]
  end

  test "put_from_name" do
    email = Email.put_from_name(Email.build(), "John Doe")
    assert email.from_name == "John Doe"
  end

  test "put_reply_to" do
    email = Email.put_reply_to(Email.build(), "test@email.com")
    assert email.reply_to == "test@email.com"
  end

  test "put_subject" do
    email = Email.put_subject(Email.build(), "Some Subject")
    assert email.subject == "Some Subject"
  end

  test "put_text" do
    email = Email.put_text(Email.build(), "Text")
    assert email.text == "Text"
  end

  test "put_html" do
    email = Email.put_html(Email.build(), "<html></html>")
    assert email.html == "<html></html>"
  end

  test "put_template" do
    email = Email.put_template(Email.build(), "unique-id")
    assert email.x_smtpapi == %{ filters: %{ templates: %{ settings: %{ enable: 1, template_id: "unique-id" } } } }
  end

  test "add_substitution" do
    email = Email.add_substitution(Email.build(), "-someValue-", "Cool")
    assert email.sub == %{ "-someValue-" => ["Cool"] }
  end

  test "add_subtitution x2" do
    email = Email.add_substitution(Email.build(), "-someValue-", "Cool")
      |> Email.add_substitution("-newValue-", "Panda")
    assert email.sub == %{ "-someValue-" => ["Cool"], "-newValue-" => ["Panda"] }
  end

end