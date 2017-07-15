defmodule SendGrid.Email do
  @moduledoc """
  Email primitive for composing emails with SendGrid's API.

  You can easily compose on an Email to set the fields of your email.
  
  ## Example

      Email.build()
      |> Email.add_to("test@email.com")
      |> Email.put_from("test2@email.com")
      |> Email.put_subject("Hello from Elixir")
      |> Email.put_text("Sent with Elixir")
      |> SendGrid.Mailer.send()

  ## SendGrid Specific Features

  Many common features of SendGrid V3 API for transactional emails are supported.

  ### Templates

  You can use a SendGrid template by providing a template id.

      put_template(email, "some_template_id")

  ### Substitutions

  You can provided a key-value pair for subsititions to have text replaced.

      add_substitution(email, "-key-", "value")

  ### Scheduled Sending

  You can provide a Unix timestamp to have an email delivered in the future.

      send_at(email, 1409348513)

  ## Phoenix Views

  You can use Phoenix Views to set your HTML and text content of your emails. You just have 
  to provide a view module and template name and you're good to go! Additionally, you can set 
  a layout to render the view in with `put_phoenix_layout/2`. See `put_phoenix_template/3` 
  for complete usage.

  ### Examples

      # Using an HTML template
      %Email{}
      |> put_phoenix_view(MyApp.Web.EmailView)
      |> put_phoenix_template("welcome_email.html", user: user)

      # Using a text template
      %Email{}
      |> put_phoenix_view(MyApp.Web.EmailView)
      |> put_phoenix_template("welcome_email.txt", user: user)

      # Using both an HTML and text template
      %Email{}
      |> put_phoenix_view(MyApp.Web.EmailView)
      |> put_phoenix_template(:welcome_email, user: user)
      
      # Setting the layout
      %Email{}
      |> put_phoenix_layout({MyApp.Web.EmailView, :layout})
      |> put_phoenix_view(MyApp.Web.EmailView)
      |> put_phoenix_template(:welcome_email, user: user)


  ### Using a Default Phoenix View

  You can set a default Phoenix View to use for rendering templates. Just set the `:phoenix_view` 
  config value.

      config :sendgrid,
        phoenix_view: MyApp.Web.EmailView


  ### Using a Default View Layout

  You can set a default layout to render the view in. Just set the `:phoenix_layout` config value.

      config :sendgrid,
        phoenix_layout: {MyApp.Web.EmailView, :layout}

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
            attachments: nil,
            __phoenix_view__: nil,
            __phoenix_layout__: nil


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
                    attachments: nil | [attachment],
                    __phoenix_view__: nil | atom,
                    __phoenix_layout__: nil | %{optional(:text) => String.t, optional(:html) => String.t}}

  @type recipient :: %{email: String.t, name: String.t | nil}
  @type content :: %{type: String.t, value: String.t}
  @type header :: {String.t, String.t}
  @type attachment :: %{content: String.t, type: String.t, filename: String.t, disposition: String.t, content_id: String.t}

  @type substitutions :: %{String.t => String.t}
  @type custom_args :: %{String.t => String.t}

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

  @doc """
  Sets the layout to use for the Phoenix Template.

  Expects a tuple of the view module and layout to use. If you provide an atom as the second element, 
  the text and HMTL versions of that template will be used for the respective content types.

  Alernatively, you can set a default layout to use by setting the `:phoenix_view` key in your config as 
  an atom which will be used for both text and HTML emails.

      config :sendgrid,
        phoenix_layout: {MyApp.Web.EmailView, :layout}

  ## Examples

      put_phoenix_layout(email, {MyApp.Web.EmailView, "layout.html"})
      put_phoenix_layout(email, {MyApp.Web.EmailView, "layout.txt"})
      put_phoenix_layout(email, {MyApp.Web.EmailView, :layout})

  """
  @spec put_phoenix_layout(t, {atom, atom}) :: t
  def put_phoenix_layout(%Email{} = email, {module, layout}) when is_atom(module) and is_atom(layout) do
    layouts = build_layouts({module, layout})
    %Email{email | __phoenix_layout__: layouts}
  end
  @spec put_phoenix_layout(t, {atom, String.t}) :: t
  def put_phoenix_layout(%Email{__phoenix_layout__: layouts} = email, {module, layout}) when is_atom(module) do
    layouts = layouts || %{}
    updated_layout = build_layouts({module, layout})
    %Email{email | __phoenix_layout__: Map.merge(layouts, updated_layout)}
  end

  # Build layout map
  defp build_layouts({module, layout}) when is_atom(module) and is_atom(layout) do
    base_name = Atom.to_string(layout)
    %{
      text: {module, base_name <> ".txt"},
      html: {module, base_name <> ".html"}
    }
  end
  defp build_layouts({module, layout} = args) when is_atom(module) do
    case Path.extname(layout) do
      ".html" -> %{html: args}
      ".txt" -> %{text: args}
      _ -> raise ArgumentError, "unsupported file type"
    end 
  end

  @doc """
  Sets the Phoenix View to use.

  This will override the default Phoenix View if set in under the `:phoenix_view` 
  config value.

  ## Examples

      put_phoenix_view(email, MyApp.Web.EmailView)
  
  """
  @spec put_phoenix_view(t, atom) :: t
  def put_phoenix_view(%Email{} = email, module) when is_atom(module) do
    %Email{email | __phoenix_view__: module}
  end

  @doc """
  Renders the Phoenix template with the given assigns.

  You can set the default Phoenix View to use for your templates by setting the `:phoenix_view` config value. 
  Additionally, you can set the view on a per email basis by calling `put_phoenix_view/2`. Furthermore, you can have 
  the template rendered inside a layout. See `put_phoenix_layout/2` for more details.

  ## Explicit Template Extensions

  You can provide a template name with an explicit extension such as `"some_template.html"` or 
  `"some_template.txt"`. This is set the content of the email respective to the content type of
  the template rendered. For example, if you render an HTML template, the output of the rendering 
  will be the HTML content of the email.

  ## Implicit Template Extensions

  You can omit a template's extension and attempt to have both a text template and HTML template 
  rendered. To have both types rendered, both templates must share the same base file name. For 
  example, if you have a template named `"some_template.txt"` and a template named `"some_template.html"` 
  and you call `put_phoenix_template(email, :some_template)`, both templates will be used and will 
  set the email content for both content types. The only caveat is *both files must exist*, otherwise you'll 
  have an exception raised.

  ## Examples

      iex> put_phoenix_template(email, "some_template.html") 
      %Email{content: [%{type: "text/html", value: ...}], ...}

      iex> put_phoenix_template(email, "some_template.txt", name: "John Doe") 
      %Email{content: [%{type: "text/plain", value: ...}], ...}

      iex> put_phoenix_template(email, :some_template, user: user)
      %Email{content: [%{type: "text/plain", value: ...}, %{type: "text/html", value: ...}], ...}

  """
  def put_phoenix_template(email, template_name, assigns \\ [])
  @spec put_phoenix_template(t, atom, []) :: t
  def put_phoenix_template(%Email{} = email, template_name, assigns) when is_atom(template_name) do
    with true <- ensure_phoenix_loaded(),
         view_mod <- phoenix_view_module(email),
         layouts <- phoenix_layouts(email),
         template_name <- Atom.to_string(template_name) do
      email
      |> render_html(view_mod, template_name <> ".html", layouts, assigns)
      |> render_text(view_mod, template_name <> ".txt", layouts, assigns)
    end
  end
  @spec put_phoenix_template(t, String.t, []) :: t
  def put_phoenix_template(%Email{} = email, template_name, assigns) do
    with true <- ensure_phoenix_loaded(),
         view_mod <- phoenix_view_module(email),
         layouts <- phoenix_layouts(email) do
      case Path.extname(template_name) do
        ".html" ->
          render_html(email, view_mod, template_name, layouts, assigns)
        ".txt" ->
          render_text(email, view_mod, template_name, layouts, assigns)
      end
    end
  end

  defp render_html(email, view_mod, template_name, layouts, assigns) do
    assigns =
      if Map.has_key?(layouts, :html) do
        Keyword.put(assigns, :layout, Map.get(layouts, :html))
      else
        assigns
      end

    html = Phoenix.View.render_to_string(view_mod, template_name, assigns) 
    put_html(email, html)
  end

  defp render_text(email, view_mod, template_name, layouts, assigns) do
    assigns =
      if Map.has_key?(layouts, :text) do
        Keyword.put(assigns, :layout, Map.get(layouts, :text))
      else
        assigns
      end

    text = Phoenix.View.render_to_string(view_mod, template_name, assigns)
    put_text(email, text)
  end 

  defp ensure_phoenix_loaded do
    unless Code.ensure_loaded?(Phoenix) do
      raise ArgumentError, "Attempted to call function that depends on Phoenix. " <>
                           "Make sure Phoenix is part of your dependencies"
    end
    true
  end

  defp phoenix_layouts(%Email{__phoenix_layout__: layouts}) do
    layouts = layouts || %{}
    case config(:phoenix_layout) do
      nil -> layouts
      {module, layout} when is_atom(module) and is_atom(layout) ->
        configured_layouts = build_layouts({module, layout}) 
        Map.merge(configured_layouts, layouts)
      _ ->
        raise ArgumentError, "Invalid configuration set for :phoenix_layout. " <>
                             "Ensure the configuration is a tuple of a module and atom ({MyApp.View, :layout})."
    end
  end

  defp phoenix_view_module(%Email{__phoenix_view__: nil}) do
    mod = config(:phoenix_view)
    unless mod do
      raise ArgumentError, "Phoenix view is expected to be set or configured. " <>
                           "Ensure your config for :sendgrid includes a value for :phoenix_view or" <>
                           "explicity set the Phoenix view with `put_phoenix_view/2`."
    end
    mod
  end
  defp phoenix_view_module(%Email{__phoenix_view__: view_module}), do: view_module

  defp config(key) do
    Application.get_env(:sendgrid, key)
  end
end