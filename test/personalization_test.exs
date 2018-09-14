defmodule SendGrid.Personalization.Test do
  use ExUnit.Case, async: true
  alias SendGrid.Personalization

  @email "test@email.com"
  @name "John Doe"

  test "build/0" do
    assert Personalization.build() == %Personalization{}
  end

  test "add_to/2" do
    personalization = Personalization.add_to(Personalization.build(), @email)
    assert personalization.to == [%{email: @email}]
  end

  test "add_to/3" do
    personalization = Personalization.add_to(Personalization.build(), @email, @name)
    assert personalization.to == [%{email: @email, name: @name}]
  end

  test "add_to with multiple addresses" do
    personalization =
      Personalization.build()
      |> Personalization.add_to(@email)
      |> Personalization.add_to(@email, @name)

    assert personalization.to == [%{email: @email}, %{email: @email, name: @name}]
  end

  test "add_cc/2" do
    personalization = Personalization.add_cc(Personalization.build(), @email)
    assert personalization.cc == [%{email: @email}]
  end

  test "add_cc/3" do
    personalization = Personalization.add_cc(Personalization.build(), @email, @name)
    assert personalization.cc == [%{email: @email, name: @name}]
  end

  test "add_cc with multiple addresses" do
    personalization =
      Personalization.build()
      |> Personalization.add_cc(@email)
      |> Personalization.add_cc(@email, @name)

    assert personalization.cc == [%{email: @email}, %{email: @email, name: @name}]
  end

  test "add_bcc/2" do
    personalization = Personalization.add_bcc(Personalization.build(), @email)
    assert personalization.bcc == [%{email: @email}]
  end

  test "add_bcc/3" do
    personalization = Personalization.add_bcc(Personalization.build(), @email, @name)
    assert personalization.bcc == [%{email: @email, name: @name}]
  end

  test "add_bcc with multiple addresses" do
    personalization =
      Personalization.build()
      |> Personalization.add_bcc(@email)
      |> Personalization.add_bcc(@email, @name)

    assert personalization.bcc == [%{email: @email}, %{email: @email, name: @name}]
  end

  test "put_subject/2" do
    subject = "Test Subject"
    personalization = Personalization.put_subject(Personalization.build(), subject)
    assert personalization.subject == subject
  end

  test "add_header/3" do
    header_key = "SOME_KEY"
    header_value = "SOME_VALUE"

    personalization =
      Personalization.add_header(Personalization.build(), header_key, header_value)

    assert personalization.headers == [{header_key, header_value}]
  end

  test "add_substitution/3" do
    personalization =
      Personalization.add_substitution(Personalization.build(), "-someValue-", "Cool")

    assert personalization.substitutions == %{"-someValue-" => "Cool"}
  end

  test "add_subtitution/3 x2" do
    personalization =
      Personalization.build()
      |> Personalization.add_substitution("-someValue-", "Cool")
      |> Personalization.add_substitution("-newValue-", "Panda")

    assert personalization.substitutions == %{"-someValue-" => "Cool", "-newValue-" => "Panda"}
  end

  test "add_custom_arg/3" do
    personalization =
      Personalization.add_custom_arg(Personalization.build(), "unique_user_id", "abc123")

    assert personalization.custom_args == %{"unique_user_id" => "abc123"}
  end

  test "add_custom_arg/3 x2" do
    personalization =
      Personalization.build()
      |> Personalization.add_custom_arg("unique_user_id", "abc123")
      |> Personalization.add_custom_arg("template_name", "welcome-user")

    assert personalization.custom_args == %{
             "unique_user_id" => "abc123",
             "template_name" => "welcome-user"
           }
  end

  test "add_custom_arg/3 does not create duplicate keys" do
    personalization =
      Personalization.build()
      |> Personalization.add_custom_arg("unique_user_id", "abc123")
      |> Personalization.add_custom_arg("template_name", "welcome-user")
      |> Personalization.add_custom_arg("template_name", "new_template")

    assert personalization.custom_args == %{
             "unique_user_id" => "abc123",
             "template_name" => "new_template"
           }
  end

  test "put_send_at/2" do
    time = 123_456_789
    personalization = Personalization.put_send_at(Personalization.build(), time)
    assert personalization.send_at == time
  end
end
