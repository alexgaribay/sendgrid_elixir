# Architecture Summary

Elixir wrapper for SendGrid v3 REST API. Uses Tesla for HTTP and Jason for JSON.

## Components

- **SendGrid** — HTTP client core (GET/POST/PATCH/DELETE with API key management)
- **SendGrid.Email** — Composable email builder struct with pipeline-friendly API
- **SendGrid.Mail** — Sends emails via POST /v3/mail/send
- **SendGrid.Personalization** — Per-recipient overrides (to, cc, bcc, subject, headers, dynamic data)
- **SendGrid.Templates / DynamicTemplate / LegacyTemplate** — Template CRUD with dynamic/legacy dispatch
- **SendGrid.Template.Version(s)** — Template version management
- **SendGrid.Contacts.Lists** — Marketing campaign list operations
- **SendGrid.Contacts.Recipients** — Contact management

## Key Patterns

- Pipeline-style composable builder for emails
- Jason.Encoder protocol implementations strip nil fields
- Pattern matching on `"generation"` field for template type dispatch
- Optional Phoenix view integration for email content rendering
- Runtime API key via `{:system, "ENV_VAR"}` tuples

## Stack

Elixir ~> 1.4, Tesla ~> 1.2, Jason ~> 1.1, Phoenix ~> 1.6 (optional/test). Config key: `:noizu_sendgrid`.
