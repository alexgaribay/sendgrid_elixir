# Changelog

## 2.0.0 (2019-03-15)

### Enhancements
  * Switch from using `HTTPoison` to using `Tesla`
  * Switch from using `Poison` to `Jason` for JSON serialization
  * `SendGrid.Email` is now responsible for configuring its own JSON serialization
  * An API key can be set manually for any API call as a keyword option, bypassing
    the need for a global API key
  * An API key can be set with the `{:system, "ENV_VAR"}` to use values at runtime
  * Add Dialyzer for validating typespecs
  * Add support for dynamic template data
  * Add struct for handling Contact Recipient encoding
  * Working config added for testing
  * Add support for multiple personalizations in a single sent Email request

### Bug Fixes
  * Typespecs are now correct

### Breaking Changes
  * `SendGrid.Mailer` has been renamed to `SendGrid.Mail` to better reflect the
    actual shape of SendGrid's API structure
  * `SendGrid.Contacts.Recipients.add` now requires a recipient to be built with
    `SendGrid.Contacts.Recipient.build/2`
  * `SendGrid.Contacts.Lists.add` returns `{:ok, map()}` instead of `{:ok, integer()}`.

## 1.8.0 (2018-01-18)

### Enhancements
  * Raise runtime error whenever API isn't configured whenever making an API call

### Bug Fixes
  * custom headers are properly sent when V3 of the SendGrid API

## 1.7.0 (2017-09-11)

### Enhancements
  * Add `add/1`, `all_recipients/3`, and `delete_recipient/2` to `SendGrid.Contacts.Lists`
  * Remove compile warnings for `Phoenix.View`

## 1.6.0 (2017-07-14)

### Enhancements
  * Relax dependency versions
  * add `put_phoenix_layout/2` in `SendGrid.Email` to render views in
### Breaking Changes
  * `put_phoenix_template/3` now expects an atom for implicit template rendering

## 1.5.0 (2017-07-3)

### Enhancements
  * update docs
  * upgrade to Elixir 1.4
  * add support for Phoenix Views

## 1.4.0 (2017-02-15)

### Enhancements
  * update `httpoison` to 0.11.0 and `poison` to 3.0
  * clean up compiler warnings when using Elixir 1.3

## 1.3.0 (2016-11-5)

### Enhancements
  * add `add_custom_arg` for custom arguments
  * remove `raise` when no API key is provided at compile-time

## 1.2.0 (2016-09-28)

### Enhancements
  * add `add_attachment` for attachments
  * bump `:poison` version to 2

## 1.1.0 (2016-08-30)

### Enhancements
  * add `add_header` to be sent with an email

## 1.0.3 (2016-08-03)

### Bug Fixes
  * replace documentation using to `put_to` with `add_to`

## 1.0.2 (2016-07-20)

### Enhancements
  * [Mailer] sandbox mode is fetched during runtime instead of compile time

### Bug Fixes
  * [Mailer] add missing insertion of template id

## 1.0.1 (2016-7-16)

### Bug Fixes
  * [Email] Make an exposed method private

## 1.0.0 (2016-07-15)

### Enhancements
  * [Email] multiple TO recipients can be added with `add_to/2` and `add_to/3`
  * [Email] BCC recipients can be supported
  * [Email] Reply-to name can be specified as third param of `put_reply_to/3`
  * [Email] added `put_send_at/2` for delayed sending of email
  * [Mailer] uses V3 of the SendGrid mail send API
  * [Mailer] sandbox mode can be enabled through a config setting

### Breaking Changes
  * `put_to/2` no longer exists; use `add_to/2` or `add_to/3` instead
  * `add_cc/2` when submitting a list of addresses no longer exists
  * `put_from_name/2` no longer exists; use `put_from/3` and set the **from_name** as the third param
  * `delete_cc/2` no longer exists

## 0.1.1 (2016-07-05)

### Enhancements
  * Updated HTTPoison version for less compiler warnings when using Elixir 1.3

## 0.1.0 (2016-05-22)

### Enhancements
  * Added some API to add email addresses for marketing campaigns

### Upgrading From Prior Versions

`:sendgrid` needs to be added to the list of applications in the `mix.exs` file.

```elixir
def application do
 [applications: [:sendgrid]]
end
```

## 0.2.0 (2016-05-22)

### Bug Fixes
  * Updated some docs
