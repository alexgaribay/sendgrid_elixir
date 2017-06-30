defmodule SendGrid.Email do
  @moduledoc """
  Email primitive for composing emails with SendGrid's API.

  ## Examples

      iex> Email.build()
      ...> |> Email.add_to("test@email.com")
      ...> |> Email.put_from("test2@email.com")
      ...> |> Email.put_subject("Hello from Elixir")
      ...> |> Email.put_text("Sent with Elixir")
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

  @doc """
  Builds an an empty email to compose on.

  ## Examples

      iex> build()
      %Email{...}

  """
  @spec build :: t
  def build do
    %Email{}
  end

  @doc """
  Sets the `to` field for the email. A to-name can be passed as the third parameter.

  ## Examples

      add_to(%Email{}, "test@email.com")
      add_to(%Email{}, "test@email.com", "John Doe")

  """
  @spec add_to(t, String.t) :: t
  def add_to(%Email{to: to} = email, to_address) do
    addresses = add_address_to_list(to, to_address)
    %Email{email | to: addresses}
  end

  @spec add_to(t, String.t, String.t) :: t
  def add_to(%Email{to: to} = email, to_address, to_name) do
    addresses = add_address_to_list(to, to_address, to_name)
    %Email{email | to: addresses}
  end

  @doc """
  Sets the `from` field for the email. The from-name can be specified as the third parameter.

  ## Examples

      put_from(%Email{}, "test@email.com")
      put_from(%Email{}, "test@email.com", "John Doe")

  """
  @spec put_from(t, String.t) :: t
  def put_from(%Email{} = email, from_address) do
    %Email{email | from: address(from_address)}
  end

  @spec put_from(t, String.t, String.t) :: t
  def put_from(%Email{} = email, from_address, from_name) do
    %Email{email | from: address(from_address, from_name)} 
  end

  @doc """
  Add recipients to the `CC` address field. The cc-name can be specified as the third parameter.

  ## Examples

      add_cc(%Email{}, "test@email.com")
      add_cc(%Email{}, "test@email.com", "John Doe")

  """
  @spec add_cc(t, String.t) :: t
  def add_cc(%Email{cc: cc} = email, cc_address) do
    addresses = add_address_to_list(cc, cc_address)
    %Email{email | cc: addresses}
  end

  @spec add_cc(Email.t, String.t, String.t) :: Email.t
  def add_cc(%Email{cc: cc} = email, cc_address, cc_name) do
    addresses = add_address_to_list(cc, cc_address, cc_name)
    %Email{email | cc: addresses}
  end

  @doc """
  Add recipients to the `BCC` address field. The bcc-name can be specified as the third parameter.

  ## Examples

      add_bcc(%Email{}, "test@email.com")
      add_bcc(%Email{}, "test@email.com", "John Doe")

  """
  @spec add_bcc(t, String.t) :: t
  def add_bcc(%Email{bcc: bcc} = email, bcc_address) do
    addresses = add_address_to_list(bcc, bcc_address)
    %Email{email | bcc: addresses}
  end

  @spec add_bcc(t, String.t, String.t) :: t
  def add_bcc(%Email{bcc: bcc} = email, bcc_address, bcc_name) do
    addresses = add_address_to_list(bcc, bcc_address, bcc_name)
    %Email{email | bcc: addresses}
  end

  @doc """
  Adds an attachment to the email. 
  
  An attachment is a map with the keys:

    * `:content`
    * `:type`
    * `:filename`
    * `:disposition`
    * `:content_id`

  ## Examples

      attachment = %{content: "base64string", filename: "image.jpg"}
      add_attachment(%Email{}, attachment}

  """
  @spec add_attachment(t, attachment) :: t
  def add_attachment(%Email{} = email, attachment) do
    attachments = 
      case email.attachments do
        nil -> [attachment]
        list -> list ++ [attachment]
      end
    %Email{email | attachments: attachments}
  end

  @doc """
  Sets the `reply_to` field for the email. The reply-to name can be specified as the third parameter.

  ## Examples

      put_reply_to(%Email{}, "test@email.com")
      put_reply_to(%Email{}, "test@email.com", "John Doe")

  """
  @spec put_reply_to(t, String.t) :: t
  def put_reply_to(%Email{} = email, reply_to_address) do
    %Email{email | reply_to: address(reply_to_address)}
  end

  @spec put_reply_to(t, String.t, String.t) :: t
  def put_reply_to(%Email{} = email, reply_to_address, reply_to_name) do
    %Email{email | reply_to: address(reply_to_address, reply_to_name)}
  end

  @doc """
  Sets the `subject` field for the email.

  ## Examples
  
      put_subject(%Email{}, "Hello from Elixir")

  """
  @spec put_subject(t, String.t) :: t
  def put_subject(%Email{} = email, subject) do
    %Email{email | subject: subject}
  end

  @doc """
  Sets `text` content of the email.

  ## Examples

      put_text(%Email{}, "Sent from Elixir!")

  """
  @spec put_text(t, String.t) :: t
  def put_text(%Email{content: [%{type: "text/plain"} | tail]} = email, text_body) do
    content = [%{type: "text/plain", value: text_body} | tail]
    %Email{email | content: content}
  end
  def put_text(%Email{content: content} = email, text_body) do
    content = [%{type: "text/plain", value: text_body} | List.wrap(content)]  
    %Email{email | content: content}
  end

  @doc """
  Sets the `html` content of the email.

  ## Examples

      Email.put_html(%Email{}, "<html><body><p>Sent from Elixir!</p></body></html>")

  """
  @spec put_html(t, String.t) :: t
  def put_html(%Email{content: [head | %{type: "text/html"}]} = email, html_body) do
    content = [head | %{type: "text/html", value: html_body}]
    %Email{email | content: content}
  end
  def put_html(%Email{content: content} = email, html_body) do
    content = List.wrap(content) ++ [%{type: "text/html", value: html_body}]
    %Email{email | content: content}
  end

  @doc """
  Sets a custom header.

  ## Examples

      Email.add_header(%Email{}, "HEADER_KEY", "HEADER_VALUE")

  """
  @spec add_header(t, String.t, String.t) :: t
  def add_header(%Email{headers: nil} = email, header_key, header_value) do
    %Email{email | headers: [{header_key, header_value}]}
  end
  def add_header(%Email{headers: [_|_] = headers} = email, header_key, header_value) do
    headers = headers ++ [{header_key, header_value}]
    %Email{email | headers: headers}
  end
  
  @doc """
  Uses a predefined SendGrid template for the email.

  ## Examples

      Email.put_template(%Email{}, "the_template_id")

  """
  @spec put_template(t, String.t) :: t
  def put_template(%Email{} = email, template_id) do
    %Email{email | template_id: template_id}
  end

  @doc """
  Adds a substitution value to be used with a template.

  If a substitution for a given name is already set, it will be replaced when adding 
  a substitution with the same name.

  ## Examples

      Email.add_substitution(%Email{}, "-sentIn-", "Elixir")

  """
  @spec add_substitution(t, String.t, String.t) :: t
  def add_substitution(%Email{substitutions: substitutions} = email, sub_name, sub_value) do
    substitutions = Map.put(substitutions || %{}, sub_name, sub_value)
    %Email{email | substitutions: substitutions}
  end

  @doc """
  Adds a custom_arg value to the email.

  If an argument for a given name is already set, it will be replaced when adding 
  a argument with the same name.

  ## Examples

      Email.add_custom_arg(%Email{}, "-sentIn-", "Elixir")

  """
  @spec add_custom_arg(t, String.t, String.t) :: t
  def add_custom_arg(%Email{custom_args: custom_args} = email, arg_name, arg_value) do
    custom_args = Map.put(custom_args || %{}, arg_name, arg_value)
    %Email{email | custom_args: custom_args}
  end

  @doc """
  Sets a future date of when to send the email.

  ## Examples

      Email.put_send_at(%Email{}, 1409348513)

  """
  @spec put_send_at(t, integer) :: t
  def put_send_at(%Email{} = email, send_at) do
    %Email{email | send_at: send_at}
  end

  defp address(email), do: %{email: email}
  defp address(email, name), do: %{email: email, name: name}

  defp add_address_to_list(nil, email) do
    [address(email)]
  end
  defp add_address_to_list(list, email) when is_list(list) do
    list ++ [address(email)]
  end
  defp add_address_to_list(nil, email, name) do
    [address(email, name)]
  end
  defp add_address_to_list(list, email, name) when is_list(list) do
     list ++ [address(email, name)]
  end
end