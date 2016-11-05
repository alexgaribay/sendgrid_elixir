defmodule SendGrid.Email do
  @moduledoc """
  Email primitive for composing emails with SendGrid's API.

      Email.build()
        |> Email.add_to("test@email.com")
        |> Email.put_from("test2@email.com")
        |> Email.put_subject("Hello from Elixir")
        |> Email.put_text("Sent with Elixir")

      %Email{
        to: %{ email: "test@email.com" },
        from %{ email: "test2@email.com" },
        subject: "Hello from Elixir",
        content: [%{ type: "text/plain", value: "Sent with Elixir" }],
        ...
      }

  """

  alias __MODULE__
  defstruct to: nil,
            cc: nil,
            bcc: nil,
            from: nil,
            reply_to: nil,
            subject: nil,
            content: nil,
            template_id: nil,
            substitutions: nil,
            custom_args: nil,
            send_at: nil,
            headers: nil,
            attachments: nil


  @type t :: %Email{to: nil | [recipient],
                    cc: nil | [recipient],
                    bcc: nil | [recipient],
                    from: nil | recipient,
                    reply_to: nil | recipient,
                    subject: nil | String.t,
                    content: nil | [content],
                    template_id: nil | String.t,
                    substitutions: nil | substitutions,
                    custom_args: nil | custom_args,
                    send_at: nil | integer,
                    headers: nil | [header],
                    attachments: nil | [attachment]}

  @type recipient :: %{ email: String.t, name: String.t | nil }
  @type content :: %{ type: String.t, value: String.t }
  @type header :: { String.t, String.t }
  @type attachment :: %{content: String.t, type: String.t, filename: String.t, disposition: String.t, content_id: String.t}

  @type substitutions :: %{ String.t => String.t }
  @type custom_args :: %{ String.t => String.t }

  @doc"""
  Builds an an empty email to compose on.

      Email.build()
      # %Email{...}

  """
  @spec build() :: Email.t
  def build() do
    %Email{}
  end

  @doc """
  Sets the `to` field for the email. A to-name can be passed as the third parameter.

      Email.add_to(%Email{}, "test@email.com")

      Email.add_to(%Email{}, "test@email.com", "John Doe")

  """
  @spec add_to(Email.t, String.t) :: Email.t
  def add_to(%Email{} = email, to_address) do
    put_in(email.to, add_address_to_list(email.to || [], to_address))
  end

  @spec add_to(Email.t, String.t, String.t) :: Email.t
  def add_to(%Email{} = email, to_address, to_name) do
    put_in(email.to,  add_address_to_list(email.to || [], to_address, to_name))
  end

  @doc """
  Sets the `from` field for the email. The from-name can be specified as the third parameter.

      Email.put_from(%Email{}, "test@email.com")

      Email.put_from(%Email{}, "test@email.com", "John Doe")

  """
  @spec put_from(Email.t, String.t) :: Email.t
  def put_from(%Email{} = email, from_address) do
    put_in(email.from, %{ email: from_address })
  end

  @spec put_from(Email.t, String.t, String.t) :: Email.t
  def put_from(%Email{} = email, from_address, from_name) do
    put_in(email.from, %{ email: from_address, name: from_name })
  end

  @doc """
  Add recipients to the `CC` address field. The cc-name can be specified as the third parameter.

      Email.add_cc(%Email{}, "test@email.com")

      Email.add_cc(%Email{}, "test@email.com", "John Doe")

  """
  @spec add_cc(Email.t, String.t) :: Email.t
  def add_cc(%Email{} = email, cc_address) do
    put_in(email.cc, add_address_to_list(email.cc || [], cc_address))
  end

  @spec add_cc(Email.t, String.t, String.t) :: Email.t
  def add_cc(%Email{} = email, cc_address, cc_name) do
    put_in(email.cc, add_address_to_list(email.cc || [], cc_address, cc_name))
  end

  @doc """
  Add recipients to the `BCC` address field. The bcc-name can be specified as the third parameter.

      Email.add_bcc(%Email{}, "test@email.com")

      Email.add_bcc(%Email{}, "test@email.com", "John Doe")

  """
  @spec add_bcc(Email.t, String.t) :: Email.t
  def add_bcc(%Email{} = email, bcc_address) do
    put_in(email.bcc, add_address_to_list(email.bcc || [], bcc_address))
  end

  @spec add_bcc(Email.t, String.t, String.t) :: Email.t
  def add_bcc(%Email{} = email, bcc_address, bcc_name) do
    put_in(email.bcc, add_address_to_list(email.bcc || [], bcc_address, bcc_name))
  end

  @doc """
  Adds an attachment to the email. An attachment is a map with the keys:
    * content
    * type
    * filename
    * disposition
    * content_id

      attachment = %{content: "base64string", filename: "image.jpg"}
      Email.add_attachment(%Email{}, attachemnt}

  """
  @spec add_attachment(Email.t, Attachment.t) :: Email.t
  def add_attachment(%Email{} = email, attachment) do
    attachments = case email.attachments do
      nil -> [attachment]
      list -> list ++ [attachment]
    end
    %{email | attachments: attachments}
  end

  @doc """
  Sets the `reply_to` field for the email. The reply-to name can be specified as the third parameter.

      Email.put_reply_to(%Email{}, "test@email.com")

      Email.put_reply_to(%Email{}, "test@email.com", "John Doe")

  """
  @spec put_reply_to(Email.t, String.t) :: Email.t
  def put_reply_to(%Email{} = email, reply_to_address) do
    put_in(email.reply_to, %{ email: reply_to_address })
  end

  @spec put_reply_to(Email.t, String.t, String.t) :: Email.t
  def put_reply_to(%Email{} = email, reply_to_address, reply_to_name) do
    put_in(email.reply_to, %{ email: reply_to_address, name: reply_to_name} )
  end

  @doc """
  Sets the `subject` field for the email.

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
    case email.content do
      [ %{ type: "text/plain" } | tail ] ->
        put_in(email.content, [%{ type: "text/plain", value: text_body } | tail ])
      _ ->
        put_in(email.content,  [%{ type: "text/plain", value: text_body }] ++ (email.content || []))
    end
  end

  @doc """
  Sets the `html` content of the email.

      Email.put_html(%Email{}, "<html><body><p>Sent from Elixir!</p></body></html>")

  """
  @spec put_html(Email.t, String.t) :: Email.t
  def put_html(%Email{} = email, html_body) do
    case email.content do
      [ head | %{ type: "text/html" } ] ->
        put_in(email.content, [head | %{ type: "text/html", value: html_body }])
      _ ->
        put_in(email.content, (email.content || []) ++ [%{ type: "text/html", value: html_body }])
    end
  end

  @doc """
  Sets an custom header.

      Email.add_header(%Email{}, "HEADER_KEY", "HEADER_VALUE")

  """
  @spec add_header(Email.t, String.t, String.t) :: Email.t
  def add_header(%Email{} = email, header_key, header_value) do
    case email.headers do
      nil ->
        put_in(email.headers, [{ header_key, header_value }])
      headers ->
        put_in(email.headers, headers ++ [{ header_key, header_value }])
    end
  end

  @doc """
  Uses a predefined template for the email.

      Email.put_template(%Email{}, "the_template_id")

  """
  @spec put_template(Email.t, String.t) :: Email.t
  def put_template(%Email{} = email, template_id) do
    %{ email | template_id: template_id }
  end

  @doc """
  Adds a subtitution value to be used with a template.
  This function replaces existing key values.

      Email.add_substitution(%Email{}, "-sentIn-", "Elixir")

  """
  @spec add_substitution(Email.t, String.t, String.t) :: Email.t
  def add_substitution(%Email{} = email, sub_name, sub_value) do
    put_in(email.substitutions, Map.put(email.substitutions || %{}, sub_name, sub_value))
  end

  @doc """
  Adds a custom_arg value to the email.
  This function replaces existing key values.

      Email.add_custom_arg(%Email{}, "-sentIn-", "Elixir")

  """
  @spec add_custom_arg(Email.t, String.t, String.t) :: Email.t
  def add_custom_arg(%Email{} = email, sub_name, sub_value) do
    put_in(email.custom_args, Map.put(email.custom_args || %{}, sub_name, sub_value))
  end

  @doc """
  Sets a future date of when to send the email.

      Email.put_send_at(%Email{}, 1409348513)

  """
  @spec put_send_at(Email.t, integer) :: Email.t
  def put_send_at(%Email{} = email, send_at) do
    %{ email | send_at: send_at }
  end

  defp add_address_to_list(list, address), do: list ++ [%{ email: address }]
  defp add_address_to_list(list, address, name), do: list ++ [%{ email: address, name: name }]

end
