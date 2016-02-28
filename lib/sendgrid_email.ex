defmodule SendGrid.Email do
  @moduledoc """
  Email primitive for composing emails with SendGrid's API.

      email =
        Email.build()
        |> Email.put_to("test@email.com")
        |> Email.put_from("test2@email.com")
        |> Email.put_subject("Hello from Elixir")
        |> Email.put_text("Sent with Elixir")

      %Email{
        to: "test@email.com",
        from "test2@email.com",
        subject: "Hello from Elixir",
        text: "Sent with Elixir"
      }

  """

  alias __MODULE__
  defstruct to: nil, cc: nil, bcc: nil, from: nil, from_name: nil, reply_to: nil,
            subject: nil, text: nil, html: nil, x_smtpapi: nil, sub: nil


  @type t :: %Email{to: String.t,
                    cc: nil | list(String.t),
                    bcc: nil | list(String.t),
                    from: String.t,
                    from_name: nil | String.t,
                    reply_to: nil | String.t,
                    subject: nil | String.t,
                    text: nil | String.t,
                    html: nil | String.t,
                    x_smtpapi: nil | template,
                    sub: nil | substitution }

  @type template :: %{ filters: %{ templates: %{ settings: %{ enable: 1, templated_id: String.t } } } }
  # TODO make the representation more accuratate
  @type substitution :: %{ String.t => list(String.t) }

  @doc"""
  Builds an an empty email to compose on.

      Email.build()
      %Email{}

  """
  @spec build() :: Email.t
  def build() do
    %Email{}
  end

  @doc """
  Sets the `to` field for the email.

      Email.put_to(%Email{}, "test@email.com")

  """
  @spec put_to(Email.t, String.t) :: Email.t
  def put_to(%Email{} = email, to_address) do
    %{ email | to: to_address }
  end

  @doc """
  Sets the `from` field for the email.

      Email.put_from(%Email{}, "test@email.com")

  """
  @spec put_from(Email.t, String.t) :: Email.t
  def put_from(%Email{} = email, from_address) do
    %{ email | from: from_address }
  end

  @doc """
  Add recipients to the `CC` address field.

  CC recipients can be added as a single string or a list of strings.

      Email.add_cc(%Email{}, ["test1@email.com", "test2@email.com"])

      Email.add_cc(%Email{}, "test@email.com")

  """
  @spec add_cc(Email.t, list(String.t)) :: Email.t
  def add_cc(%Email{} = email, cc_addresses) when is_list(cc_addresses) do
    put_in(email.cc, cc_addresses ++ (email.cc || []))
  end

  @spec add_cc(Email.t, String.t) :: Email.t
  def add_cc(%Email{} = email, cc_address) do
    put_in(email.cc, [ cc_address | (email.cc || []) ])
  end

  @doc """
  Deletes a single CC address from the email.

      Email.delete_cc(%Email{cc:["test@email.com"], "test@email.com"))
      %Email{cc:[]}

  """
  @spec delete_cc(Email.t, String.t) :: Email.t
  def delete_cc(%Email{} = email, cc_address) do
    put_in(email.cc, List.delete(email.cc || [], cc_address))
  end

  @doc """
  Sets the `from_name` field for the email.

      Email.put_from_name(%Email{}, "John Doe")

  """
  @spec put_from_name(Email.t, String.t) :: Email.t
  def put_from_name(%Email{} = email, from_name_address) do
    %{ email | from_name: from_name_address }
  end


  @doc """
  Sets the `reply_to` field for the email.

      Email.put_reply_to(%Email{}, "test@email.com")

  """
  @spec put_reply_to(SendGrind.Email.t, String.t) :: Email.t
  def put_reply_to(%Email{} = email, reply_to_address) do
    %{ email | reply_to: reply_to_address }
  end

  @doc """
  Sets the `subject` field for the email.

  Setting the subject with a template changes your actual subject to be the predefined
  template concatenated with the subject being set.

      Email.put_subject(%Email{}, "Hello from Elixir")

  """
  @spec put_subject(Email.t, String.t) :: Email.t
  def put_subject(%Email{} = email, subject) do
    %{ email | subject: subject }
  end

  @doc """
  Sets `text` content of the email.

      Email.put_text(%Email{}, "Sent from Elixir!")

  """
  @spec put_text(Email.t, String.t) :: Email.t
  def put_text(%Email{} = email, text_body) do
    %{ email | text: text_body }
  end

  @doc """
  Sets the `html` content of the email.

      Email.put_html("\<html\>\<body\>\<p>Sent from Elixir!\</p\>\</body\>\</html>\")

  """
  @spec put_html(Email.t, String.t) :: Email.t
  def put_html(%Email{} = email, html_body) do
    %{ email | html: html_body }
  end

  @doc """
  Uses a predefined template for the email.

      Email.put_template(%Email{}, "the_template_id")

  """
  @spec put_template(Email.t, String.t) :: Email.t
  def put_template(%Email{} = email, template_id) do
    template = %{
      filters: %{
        templates: %{
          settings: %{
            enable: 1,
            template_id: template_id
          }
        }
      }
    }

    %{ email | x_smtpapi: template }
  end

  @doc """
  Adds a subtitution value to be used with a template.
  This function replaces existing key values.

      Email.add_substitution(%Email{}, "-sentIn-", "Elixir")

  """
  @spec add_substitution(Email.t, String.t, String.t) :: Email.t
  def add_substitution(%Email{} = email, sub_name, sub_value) do
    put_in(email.sub, Map.put(email.sub || %{}, sub_name, [sub_value]))
  end

end