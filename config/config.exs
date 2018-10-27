use Mix.Config

config :sendgrid,
  api_key: {:system, "SENDGRID_API_KEY"},
  sandbox_enable: true,
  phoenix_view: SendGrid.EmailView,
  test_address: System.get_env("SENDGRID_TEST_EMAIL")
