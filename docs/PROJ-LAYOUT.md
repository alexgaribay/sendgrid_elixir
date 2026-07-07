# Project Layout

```
sendgrid_elixir/
├── lib/
│   ├── sendgrid.ex                         # Top-level API client (HTTP get/post/patch/delete via Tesla)
│   └── sendgrid/
│       ├── email.ex                        # Email struct and composable builder functions
│       ├── mail.ex                         # Sends composed emails via SendGrid v3 API
│       ├── personalization.ex              # Personalization struct for per-recipient overrides
│       ├── response.ex                     # Response struct (body, headers, status)
│       ├── marketing_campaigns/
│       │   └── contacts/
│       │       ├── lists.ex                # Contact list CRUD
│       │       ├── recipient.ex            # Single recipient struct
│       │       └── recipients.ex           # Recipient collection operations
│       └── templates/
│           ├── template.ex                 # Template struct and CRUD
│           ├── templates.ex                # Template listing/search
│           ├── metadata.ex                 # Template metadata struct
│           ├── dynamic_template.ex         # Dynamic (handlebars) template support
│           ├── legacy_template.ex          # Legacy substitution-tag templates
│           └── template/
│               ├── version.ex              # Template version struct
│               └── versions.ex             # Template version operations
├── config/
│   └── config.exs                          # App config (:noizu_sendgrid key, API key, sandbox mode)
├── test/
│   ├── test_helper.exs                     # ExUnit bootstrap
│   ├── email_test.exs                      # Email builder unit tests
│   ├── mail_test.exs                       # Integration tests (requires API key)
│   ├── templates_test.exs                  # Template CRUD tests
│   └── support/
│       ├── email_view.ex                   # Phoenix view for test rendering
│       └── templates/email/                # EEx templates for Phoenix view tests
├── .formatter.exs                          # Elixir formatter config
├── mix.exs                                 # Project definition (app: :noizu_sendgrid)
├── mix.lock                                # Dependency lock
├── LICENSE                                 # MIT
├── README.md                               # Usage guide and configuration
└── CHANGELOG.md                            # Version history
```

## Key Configuration

| Item | Location | Notes |
|------|----------|-------|
| App name | `mix.exs` | `:noizu_sendgrid` |
| API key | `config/config.exs` | `config :noizu_sendgrid, api_key: ...` |
| Sandbox mode | `config/config.exs` | `sandbox_enable: true` for dev/test |
| Phoenix view | `config/config.exs` | Optional `:phoenix_view` for template rendering |
