# Changelog

## 1.0.2 (2016-7-20)

* Enhancements
  * [Mailer] sandbox mode is fetched during runtime instead of compile time

* Fixes
  * [Mailer] add missing insertion of template id

## 1.0.1 (2016-7-16)

* Fixes
  * [Email] Make an exposed method private 

## 1.0.0 (2016-7-15)

* Enhancements
  * [Email] multiple TO recipients can be added with `add_to/2` and `add_to/3`
  * [Email] BCC recipients can be supported
  * [Email] Reply-to name can be specified as third param of `put_reply_to/3`
  * [Email] added `put_send_at/2` for delayed sending of email 
  * [Mailer] uses V3 of the SendGrid mail send API
  * [Mailer] sandbox mode can be enabled through a config setting
    
* Breaking Changes
  * `put_to/2` no longer exists; use `add_to/2` or `add_to/3` instead
  * `add_cc/2` when submitting a list of addresses no longer exists
  * `put_from_name/2` no longer exists; use `put_from/3` and set the **from_name** as the third param
  * `delete_cc/2` no longer exists

## 0.1.1 (2016-7-5)

* Enhancements
  * Updated HTTPoison version for less compiler warnings when using Elixir 1.3
  
## 0.1.0 (2016-5-22)

* Enhancements
  * Added some API to add email addresses for marketing campaigns

### Upgrading From Prior Versions

`:sendgrid` needs to be added to the list of applications in the `mix.exs` file.

```elixir
def application do
 [applications: [:sendgrid]]
end
```

## 0.2.0 (2016-5-22)

* Fixes
  * Updated some docs


