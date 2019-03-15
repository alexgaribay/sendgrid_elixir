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
|> SendGrid.Mail.send()
```

## Installation

Add the following code to your dependencies in your **`mix.exs`** file:

```elixir
{:sendgrid, "~> 2.0"}
```

## Configuration

In one of your configuration files, include your SendGrid API key like this:

```elixir
config :sendgrid,
  api_key: "SENDGRID_API_KEY"
```

If you want to use environment variable, use `{:system, "ENV_NAME"}` in your config:

```elixir
config :sendgrid,
  api_key: {:system, "SENDGRID_API_KEY"}
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
%SendGrid.Email{}
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

## Personalizations

Personalizations are used to identify who should receive the email as well as specifics about how you would like the email to be handled.

Personalizations allow you to define:

- `to`, `cc`, `bcc` - The recipients of your email.
- `subject` - The subject of your email.
- `headers` - Any headers you would like to include in your email.
- `substitutions` - Any substitutions you would like to be made for your email.
- `custom_args` - Any custom arguments you would like to include in your email.
- `dynamic_template_data` - Data to send along with a template.
- `send_at` - A specific time that you would like your email to be sent.

An `SendGrid.Email` automatically takes these fields and transforms them into a personalization to be sent in the email. However, you can add multiple personalizations to an email and specify different handling instructions for different copies of your email. For example, you could send the same email to both <john@example.com> and <janeexampexample@example.com>, but set each email to be delivered at different times.

### Example

```elixir
alias SendGrid.{Mail, Email}
personalization_1 =
  Email.build()
  |> Email.add_to("john@example.com")
  |> Email.put_subject("Exciting news!")
  |> Email.to_personalization()

personalization_2 =
  Email.build()
  |> Email.add_to("jane@example.com")
  |> Email.put_subject("We've some exciting news!")
  |> Email.to_personalization()

Email.build()
|> Email.put_from("news@mydomain.com")
|> Email.put_text("...")
|> Email.put_html("...")
|> Email.add_personalization(personalization_1)
|> Email.add_personalization(personalization_2)
|> Mail.send()
```

### Limitations

The SendGrid v3 API limits you to 1,000 personalizations per API request. If you need to include more than 1,000 personalizations, please divide these across multiple API requests.

## Testing

To run the unit tests you will need to create a `config/config.exs` file and provide your own SendGrid API and email address to receive a test email.

```elixir
use Mix.Config

config :sendgrid,
  api_key: "<API_KEY>",
  phoenix_view: SendGrid.Email.Test.EmailView,
  test_address: "recipient@example.com"
```

The `config` directory is excluded from the git repository so your API key and email address will not be committed.

Once configured you can run the full test suite including integration tests as follows:

```console
mix test --include integration
```
