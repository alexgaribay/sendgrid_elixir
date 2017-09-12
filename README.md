# SendGrid

A wrapper for SendGrid's API to create composable emails.
Check the [docs](https://hexdocs.pm/sendgrid/) for complete usage.

## Example

```elixir
SendGrid.Email.build()
|> SendGrid.Email.add_to("test@email.com")
|> SendGrid.Email.put_from("test2@email.com")
|> SendGrid.Email.put_subject("Hello from Elixir")
|> SendGrid.Email.put_text("Sent with Elixir")
|> SendGrid.Mailer.send()
```

## Installation

Add the following code to your dependencies in your **`mix.exs`** file:

```elixir
{:sendgrid, "~> 1.7.0"}
```

## Configuration

In one of your configuration files, include your SendGrid API key like this:

```elixir
config :sendgrid,
  api_key: "SENDGRID_API_KEY"
```

If you'd like to enable sandbox mode (emails won't send but will be validated), add the setting to your config:

```elixir
config :sendgrid,
  api_key: "SENDGRID_API_KEY",
  sandbox_enable: true
```

Add `:sendgrid` to your list of applications if using Elixir 1.3 or lower.

```elixir
defp application do
  [applications: [:sendgrid]]
end
```

## Phoenix Views

You can use Phoenix Views to set your HTML and text content of your emails. You just have 
to provide a view module and template name and you're good to go! Additionally, you can set 
a layout to render the view in with `SendGrid.Email.put_phoenix_layout/2`. See `SendGrid.Email.put_phoenix_template/3` 
for complete usage.

### Examples

```elixir
import SendGrid.Email

# Using an HTML template
%SendGrid.Email{}
|> put_phoenix_view(MyApp.Web.EmailView)
|> put_phoenix_template("welcome_email.html", user: user)

# Using a text template
%SendGridEmail{}
|> put_phoenix_view(MyApp.Web.EmailView)
|> put_phoenix_template("welcome_email.txt", user: user)

# Using both an HTML and text template
%SendGrid.Email{}
|> put_phoenix_view(MyApp.Web.EmailView)
|> put_phoenix_template(:welcome_email, user: user)


# Setting the layout
%SendGrid.Email{}
|> put_phoenix_layout({MyApp.Web.EmailView, :layout})
|> put_phoenix_view(MyApp.Web.EmailView)
|> put_phoenix_template(:welcome_email, user: user)
```

### Using a Default Phoenix View

You can set a default Phoenix View to use for rendering templates. Just set the `:phoenix_view` config value

```elixir
config :sendgrid,
  phoenix_view: MyApp.Web.EmailView
```

### Using a Default Layout

You can set a default layout to render your view in. Set the `:phoenix_layout` config value.

```elixir
config :sendgrid,
  phoenix_layout: {MyApp.Web.EmailView, :layout}
```