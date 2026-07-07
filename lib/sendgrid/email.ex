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
      |> SendGrid.Mail.send()

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

      put_send_at(email, 1409348513)

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

      config :noizu_sendgrid,
        phoenix_view: MyApp.Web.EmailView


  ### Using a Default View Layout

  You can set a default layout to render the view in. Just set the `:phoenix_layout` config value.

      config :noizu_sendgrid,
        phoenix_layout: {MyApp.Web.EmailView, :layout}

  """

  alias SendGrid.{Email, Personalization}

  defstruct to: nil,
            cc: nil,
            bcc: nil,
            from: nil,
            reply_to: nil,
            reply_to_list: nil,
            subject: nil,
            content: nil,
            template_id: nil,
            version_id: nil,
            substitutions: nil,
            custom_args: nil,
            personalizations: nil,
            send_at: nil,
            headers: nil,
            categories: nil,
            batch_id: nil,
            asm: nil,
            ip_pool_name: nil,
            mail_settings: nil,
            tracking_settings: nil,
            attachments: nil,
            dynamic_template_data: nil,
            sandbox: false,
            __phoenix_view__: nil,
            __phoenix_layout__: nil

  @type t :: %Email{
          to: nil | [recipient],
          cc: nil | [recipient],
          bcc: nil | [recipient],
          from: nil | recipient,
          reply_to: nil | recipient,
          reply_to_list: nil | [recipient],
          subject: nil | String.t(),
          content: nil | [content],
          template_id: nil | String.t(),
          version_id: nil | String.t(),
          substitutions: nil | substitutions,
          custom_args: nil | custom_args,
          personalizations: nil | [Personalization.t()],
          dynamic_template_data: nil | dynamic_template_data,
          send_at: nil | integer,
          headers: nil | headers(),
          categories: nil | [String.t],
          batch_id: nil | String.t,
          asm: nil |  asm(),
          ip_pool_name: nil | String.t,
          mail_settings: nil | mail_settings(),
          tracking_settings: nil | tracking_settings(),
          attachments: nil | [attachment],
          sandbox: boolean(),
          __phoenix_view__: nil | atom,
          __phoenix_layout__:
            nil | %{optional(:text) => String.t(), optional(:html) => String.t()}
        }

  @type recipient :: %{required(:email) => String.t(), optional(:name) => String.t()}
  @type content :: %{type: String.t(), value: String.t()}
  @type headers :: %{String.t() => String.t()}
  @type asm :: %{
                 required(:group_id) => integer,
                 optional(:groups_to_display) => [integer]
               }
  @type mail_settings :: %{
                           optional(:bypass_list_management) => bypass_filter(),
                           optional(:bypass_spam_management) => bypass_filter(),
                           optional(:bypass_bounce_management) => bypass_filter(),
                           optional(:bypass_unsubscribe_management) => bypass_filter(),
                           optional(:footer) => footer(),
                           optional(:sandbox_mode) => enable_status()
                         }
  @type attachment :: %{
          required(:content) => String.t(),
          optional(:type) => String.t(),
          required(:filename) => String.t(),
          optional(:disposition) => String.t(),
          optional(:content_id) => String.t()
        }

  @type enable_status ::%{
    required(:enable) => boolean
  }
  @type bypass_filter :: enable_status()
  @type footer :: %{
                    required(:enable) => boolean,
                    required(:text) => String.t,
                    required(:html) => String.t
                  }
  @type substitutions :: %{String.t() => String.t()}
  @type custom_args :: %{String.t() => String.t()}
  @type dynamic_template_data :: %{String.t() => String.t()}

  @type tracking_settings :: %{
                            optional(:click_tracking) => click_tracking(),
                            optional(:open_tracking) => open_tracking(),
                            optional(:subscription_tracking) => subscription_tracking(),
                            optional(:ganalytics) => google_analytics_tracking()
                          }

  @type click_tracking :: %{
                            optional(:enable) => boolean,
                            optional(:enable_text) => boolean
                          }
  @type open_tracking :: %{
                            optional(:enable) => boolean,
                            optional(:substitution_tag) => nil | String.t
                          }
  @type subscription_tracking :: %{
                                   optional(:enable) => boolean,
                                   optional(:text) => String.t,
                                   optional(:html) => String.t,
                                   optional(:substitution_tag) => String.t
                                 }
  @type google_analytics_tracking :: %{
                        optional(:enable) => boolean,
                        optional(:utm_source) => String.t,
                        optional(:utm_medium) => String.t,
                        optional(:utm_content) => String.t,
                        optional(:utm_campaign) => String.t
                      }


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
  @spec add_to(t, String.t()) :: t
  def add_to(%Email{to: to} = email, to_address) do
    addresses = add_address_to_list(to, to_address)
    %Email{email | to: addresses}
  end

  @spec add_to(t, String.t(), String.t()) :: t
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
  @spec put_from(t, String.t()) :: t
  def put_from(%Email{} = email, from_address) do
    %Email{email | from: address(from_address)}
  end

  @spec put_from(t, String.t(), String.t()) :: t
  def put_from(%Email{} = email, from_address, from_name) do
    %Email{email | from: address(from_address, from_name)}
  end

  @doc """
  Add recipients to the `CC` address field. The cc-name can be specified as the third parameter.

  ## Examples

      add_cc(%Email{}, "test@email.com")
      add_cc(%Email{}, "test@email.com", "John Doe")

  """
  @spec add_cc(t, String.t()) :: t
  def add_cc(%Email{cc: cc} = email, cc_address) do
    addresses = add_address_to_list(cc, cc_address)
    %Email{email | cc: addresses}
  end

  @spec add_cc(Email.t(), String.t(), String.t()) :: Email.t()
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
  @spec add_bcc(t, String.t()) :: t
  def add_bcc(%Email{bcc: bcc} = email, bcc_address) do
    addresses = add_address_to_list(bcc, bcc_address)
    %Email{email | bcc: addresses}
  end

  @spec add_bcc(t, String.t(), String.t()) :: t
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
  @spec put_reply_to(t, String.t()) :: t
  def put_reply_to(%Email{} = email, reply_to_address) do
    %Email{email | reply_to: address(reply_to_address)}
  end

  @spec put_reply_to(t, String.t(), String.t()) :: t
  def put_reply_to(%Email{} = email, reply_to_address, reply_to_name) do
    %Email{email | reply_to: address(reply_to_address, reply_to_name)}
  end



  @doc """
  Sets the `reply_to_list` field for email. You may not use reply_to_list and reply_to at the same time.
  """
  @spec put_reply_to_list(t, [String.t()]) :: t
  def put_reply_to_list(%Email{} = email, reply_to_addresses) do
    list = Enum.map(reply_to_addresses, fn(v) ->
      case v do
        {address, name} -> address(address, name)
        address -> address(address)
      end
    end)
    %Email{email | reply_to_list: list}
  end

  @doc """
  Set/Replace email categories.
  """
  def put_categories(%Email{} = email, categories) do
    %Email{email| categories: categories}
  end
  
  @doc """
  Add/set email category.
  """
  def put_category(%Email{} = email, category) do
    case email.categories do
      nil -> %Email{email| categories: [category]}
      v -> %Email{email| categories: Enum.uniq(v ++ [category])}
    end
  end

  @doc """
  Set batch_id
  """
  def put_batch(%Email{} = email, value) do
    %Email{email| batch_id: value}
  end

  @doc """
  Set asm
  """
  def put_asm(%Email{} = email, value) do
    %Email{email| asm: value}
  end


  @doc """
  Set ip_pool_name
  """
  def put_ip_pool(%Email{} = email, value) do
    %Email{email| ip_pool_name: value}
  end

  # Initialize mail_settings
  defp init_mail_settings(%Email{mail_settings: nil} = email) do
    %Email{email| mail_settings: %{}}
  end
  defp init_mail_settings(%Email{} = email), do: email

  @doc """
  Set email.mail_settings.bypass_list_management
  """
  def configure_list_management_bypass(%Email{} = email, enable) do
    init_mail_settings(email)
    |> put_in([Access.key(:mail_settings), :bypass_list_management], %{enable: enable})
  end

  @doc """
  Set email.mail_settings.bypass_spam_management
  """
  def configure_spam_management_bypass(%Email{} = email, enable) do
    init_mail_settings(email)
    |> put_in([Access.key(:mail_settings), :bypass_spam_management], %{enable: enable})
  end

  @doc """
  Set email.mail_settings.bypass_bounce_management
  """
  def configure_bounce_management_bypass(%Email{} = email, enable) do
    init_mail_settings(email)
    |> put_in([Access.key(:mail_settings), :bypass_bounce_management], %{enable: enable})
  end

  @doc """
  Set email.mail_settings.bypass_unsubscribe_management
  """
  def configure_unsubscribe_management_bypass(%Email{} = email, enable) do
    init_mail_settings(email)
    |> put_in([Access.key(:mail_settings), :bypass_unsubscribe_management], %{enable: enable})
  end
  
  @doc """
  Set email.mail_settings.bypass_unsubscribe_management
  """
  def put_footer(%Email{} = email, footer) do
    init_mail_settings(email)
    |> put_in([Access.key(:mail_settings), :footer], footer)
  end

  @doc """
  Set entire mail_settings field, replacing any previous settings.
  """
  def put_mail_settings(%Email{} = email, value) do
    %Email{mail_settings: value}
  end


  # Initialize track_settings
  defp init_tracking_settings(%Email{tracking_settings: nil} = email) do
    %Email{email| tracking_settings: %{}}
  end
  defp init_tracking_settings(%Email{} = email), do: email

  def configure_click_tracking(%Email{} = email, value) do
    email
    |> init_tracking_settings()
    |> put_in([Access.key(:tracking_settings), :click_tracking], value)
  end
  
  def configure_open_tracking(%Email{} = email, value) do
    email
    |> init_tracking_settings()
    |> put_in([Access.key(:tracking_settings), :open_tracking], value)
  end
  
  def configure_subscription_tracking(%Email{} = email, value) do
    email
    |> init_tracking_settings()
    |> put_in([Access.key(:tracking_settings), :subscription_tracking], value)
  end

  def configure_google_analytics(%Email{} = email, value) do
    email
    |> init_tracking_settings()
    |> put_in([Access.key(:tracking_settings), :ganalytics], value)
  end

  def put_tracking_settings(%Email{} = email, value) do
    email
    |> put_in([Access.key(:tracking_settings)], value)
  end



  @doc """
  Sets the `subject` field for the email.

  ## Examples

      put_subject(%Email{}, "Hello from Elixir")

  """
  @spec put_subject(t, String.t()) :: t
  def put_subject(%Email{} = email, subject) do
    %Email{email | subject: subject}
  end

  @doc """
  Sets `text` content of the email.

  ## Examples

      put_text(%Email{}, "Sent from Elixir!")

  """
  @spec put_text(t, String.t()) :: t
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
  @spec put_html(t, String.t()) :: t
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
  @spec add_header(t, String.t(), String.t()) :: t
  def add_header(%Email{headers: headers} = email, header_key, header_value)
      when is_binary(header_key) and is_binary(header_value) do
    new_headers = Map.put(headers || %{}, header_key, header_value)
    %Email{email | headers: new_headers}
  end

  @doc """
  Uses a predefined SendGrid template for the email.

  ## Examples

      Email.put_template(%Email{}, "the_template_id")

  """
  @spec put_template(t, String.t() | SendGrid.Template) :: t
  def put_template(%Email{} = email, template = %SendGrid.LegacyTemplate{}), do: put_template(email, template.id)
  def put_template(%Email{} = email, template = %SendGrid.DynamicTemplate{}), do: put_template(email, template.id)
  def put_template(%Email{} = email, template_id) do
    %Email{email | template_id: template_id}
  end
  
  @doc """
  Uses a predefined SendGrid template version for the email.

  ## Examples

      Email.put_template_version(%Email{}, "the_template_version_id")

  """
  @spec put_template_version(t, String.t()) :: t
  def put_template_version(%Email{} = email, version_id) when is_bitstring(version_id) do
    %Email{email | version_id: version_id}
  end
  
  
  
  @doc """
  Adds a substitution value to be used with a template.

  If a substitution for a given name is already set, it will be replaced when adding
  a substitution with the same name.

  ## Examples

      Email.add_substitution(%Email{}, "-sentIn-", "Elixir")

  """
  @spec add_substitution(t, String.t(), String.t()) :: t
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
  @spec add_custom_arg(t, String.t(), String.t()) :: t
  def add_custom_arg(%Email{custom_args: custom_args} = email, arg_name, arg_value) do
    custom_args = Map.put(custom_args || %{}, arg_name, arg_value)
    %Email{email | custom_args: custom_args}
  end

  @doc """
  Adds a custom_arg value to the email.

  If an argument for a given name is already set, it will be replaced when adding
  a argument with the same name.

  ## Examples

      Email.add_dynamic_template_data(%Email{}, "-sentIn-", "Elixir")

  """
  @spec add_dynamic_template_data(t, String.t(), String.t()) :: t
  def add_dynamic_template_data(
        %Email{dynamic_template_data: dynamic_template_data} = email,
        arg_name,
        arg_value
      ) do
    dynamic_template_data = Map.put(dynamic_template_data || %{}, arg_name, arg_value)
    %Email{email | dynamic_template_data: dynamic_template_data}
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

      config :noizu_sendgrid,
        phoenix_layout: {MyApp.Web.EmailView, :layout}

  ## Examples

      put_phoenix_layout(email, {MyApp.Web.EmailView, "layout.html"})
      put_phoenix_layout(email, {MyApp.Web.EmailView, "layout.txt"})
      put_phoenix_layout(email, {MyApp.Web.EmailView, :layout})

  """
  @spec put_phoenix_layout(t, {atom, atom}) :: t
  def put_phoenix_layout(%Email{} = email, {module, layout})
      when is_atom(module) and is_atom(layout) do
    layouts = build_layouts({module, layout})
    %Email{email | __phoenix_layout__: layouts}
  end

  @spec put_phoenix_layout(t, {atom, String.t()}) :: t
  def put_phoenix_layout(%Email{__phoenix_layout__: layouts} = email, {module, layout})
      when is_atom(module) do
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
  @spec put_phoenix_template(t, atom, list()) :: t
  def put_phoenix_template(%Email{} = email, template_name, assigns)
      when is_atom(template_name) do
    with true <- ensure_phoenix_loaded(),
         view_mod <- phoenix_view_module(email),
         layouts <- phoenix_layouts(email),
         template_name <- Atom.to_string(template_name) do
      email
      |> render_html(view_mod, template_name <> ".html", layouts, assigns)
      |> render_text(view_mod, template_name <> ".txt", layouts, assigns)
    end
  end

  @spec put_phoenix_template(t, String.t(), list()) :: t
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
      raise ArgumentError,
            "Attempted to call function that depends on Phoenix. " <>
              "Make sure Phoenix is part of your dependencies"
    end

    true
  end

  defp phoenix_layouts(%Email{__phoenix_layout__: layouts}) do
    layouts = layouts || %{}

    case config(:phoenix_layout) do
      nil ->
        layouts

      {module, layout} when is_atom(module) and is_atom(layout) ->
        configured_layouts = build_layouts({module, layout})
        Map.merge(configured_layouts, layouts)

      _ ->
        raise ArgumentError,
              "Invalid configuration set for :phoenix_layout. " <>
                "Ensure the configuration is a tuple of a module and atom ({MyApp.View, :layout})."
    end
  end

  defp phoenix_view_module(%Email{__phoenix_view__: nil}) do
    mod = config(:phoenix_view)

    unless mod do
      raise ArgumentError,
            "Phoenix view is expected to be set or configured. " <>
              "Ensure your config for :noizu_sendgrid includes a value for :phoenix_view or " <>
              "explicity set the Phoenix view with `put_phoenix_view/2`."
    end

    mod
  end

  defp phoenix_view_module(%Email{__phoenix_view__: view_module}), do: view_module

  @doc """
  Sets the email to be sent with sandbox mode enabled or disabled.

  The sandbox mode will default to what is explicitly configured with
  SendGrid's configuration.
  """
  @spec set_sandbox(t(), boolean()) :: t()
  def set_sandbox(%Email{} = email, enabled?) when is_boolean(enabled?) do
    %Email{email | sandbox: enabled?}
  end

  @doc """
  Transforms an `t:Email.t/0` to a `t:Personalization.t/0`.
  """
  @spec to_personalization(t()) :: Personalization.t()
  def to_personalization(%Email{} = email) do
    %Personalization{
      to: email.to,
      cc: email.cc,
      bcc: email.bcc,
      subject: email.subject,
      substitutions: email.substitutions,
      custom_args: email.custom_args,
      dynamic_template_data: email.dynamic_template_data,
      send_at: email.send_at,
      headers: email.headers
    }
  end

  @doc """
  Adds a `t:Personalization.t/0` to an email.
  """
  @spec add_personalization(t(), Personalization.t()) :: t()
  def add_personalization(%Email{} = email, %Personalization{} = personalization) do
    personalizations = List.wrap(email.personalizations) ++ [personalization]

    %Email{email | personalizations: personalizations}
  end

  defp config(key) do
    Application.get_env(:noizu_sendgrid, key)
  end

  defimpl Jason.Encoder do
    
    defp conditional_insert(params, email, field, as_field \\ nil) do
      cond do
        v = Map.get(email, field) -> put_in(params, [as_field || field], v)
        :else -> params
      end
    end
    
    def encode(%Email{personalizations: [_ | _]} = email, opts) do
      params = %{
                 personalizations: email.personalizations,
                 from: email.from,
                 subject: email.subject,
                 content: email.content,
                 send_at: email.send_at,
                 attachments: email.attachments,
                 headers: email.headers,
               }
               # Template
               |> then(
                    fn(params) ->
                      cond do
                        email.template_id && email.version_id -> put_in(params, [:template_id], email.template_id <> "." <> email.version_id)
                        email.template_id -> put_in(params, [:template_id], email.template_id)
                        email.version_id -> raise ArgumentError, "You must specify template if specifying template version"
                        :else -> params
                      end
                    end)
        # Reply List
               |> then(
                    fn(params) ->
                      cond do
                        email.reply_to_list && email.reply_to ->
                          raise ArgumentError, "You may not set reply_to_list and reply_to at the same time."
                        v = email.reply_to -> put_in(params, [:reply_to], v)
                        v = email.reply_to_list -> put_in(params, [:reply_to_list], v)
                        :else -> params
                      end
                    end)
        # Mail Settings
               |> conditional_insert(email, :mail_settings)
        # Track Settings
               |> conditional_insert(email, :tracking_settings, :track_settings)
        # Categories
               |> conditional_insert(email, :categories)
        # Batch
               |> conditional_insert(email, :batch_id)
        # ASM
               |> conditional_insert(email, :asm)
        # IP Pool
               |> conditional_insert(email, :ip_pool_name)
        # sandbox_mode
               |> then(
                    fn(params) ->
                      # Insure partially populated.
                      params
                      |> update_in([:mail_settings], &(&1 || %{}))
                      |> update_in([:mail_settings, :sandbox_mode], &(&1 || %{}))
                      |> update_in([:mail_settings, :sandbox_mode, :enable], fn(p) ->
                        cond do
                          is_boolean(p) -> p
                          :else -> Application.get_env(:noizu_sendgrid, :sandbox_enable, email.sandbox)
                        end
                      end)
                    end)
      
      Jason.Encode.map(params, opts)
    end

    def encode(%Email{personalizations: nil} = email, opts) do
      personalization = Email.to_personalization(email)

      email
      |> Email.add_personalization(personalization)
      |> encode(opts)
    end
  end
end
