# SendGridElixir

A wrapper for SendGrid's API to create composable emails.

## Installation

Add the following code to your dependencies in your **`mix.exs`** file:


    {:sendgrid, "~> 0.0.1"}


## Configuration

In one of your configuration files, include your SendGrid API key like this:


    config :sendgrid,
      api_key: "SENDGRID_API_KEY"


## Usage

Check the [docs](https://hexdocs.pm/sendgrid/) for complete usage.

### Simple Text Email


    alias SendGrid.{Mailer, Email}
    
    email = 
      Email.build()
      |> Email.put_from("test@email.com")
      |> Email.put_to("test2@email.com")
      |> Email.put_subject("Hello From Elixir")
      |> Email.put_text("Sent from Elixir!")
      
    Mailer.send(email)


### Simple HTML Email


    alias SendGrid.{Mailer, Email}
    
    email = 
      Email.build()
      |> Email.put_from("test@email.com")
      |> Email.put_to("test2@email.com")
      |> Email.put_subject("Hello From Elixir")
      |> Email.put_html("\<html\>\<body\>\<p>Sent from Elixir!\</p\>\</body\>\</html>\")
      
    Mailer.send(email)


### Using a Predefined Template


    alias SendGrid.Email
    
    Email.build()
      |> Email.put_template("the_template_id")
