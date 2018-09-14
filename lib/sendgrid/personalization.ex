defmodule SendGrid.Personalization do
  @moduledoc """
  Personalizations are used by SendGrid v3 API to identify who should receive
  the email as well as specifics about how you would like the email to be handled.

  Personalizations allow you to define:

    - `to`, `cc`, `bcc` - The recipients of your email.
    - `subject` - The subject of your email.
    - `headers` - Any headers you would like to include in your email.
    - `substitutions` - Any substitutions you would like to be made for your email.
    - `custom_args` - Any custom arguments you would like to include in your email.
    - `send_at` - A specific time that you would like your email to be sent.

  ## Example

      alias SendGrid.{Email, Personalization}

      personalization =
        Personalization.build()
        |> Personalization.add_to("recipient1@example.com")
        |> Personalization.add_to("recipient2@example.com")

      Email.build()
      |> Email.add_from("sender@example.com")
      |> Email.add_personalization(personalization)
      |> SendGrid.Mailer.send()

  """

  alias SendGrid.Personalization

  defstruct to: nil,
            cc: nil,
            bcc: nil,
            subject: nil,
            substitutions: nil,
            custom_args: nil,
            send_at: nil,
            headers: nil

  @type t :: %Personalization{
          to: nil | [SendGrid.Email.recipient()],
          cc: nil | [SendGrid.Email.recipient()],
          bcc: nil | [SendGrid.Email.recipient()],
          subject: nil | String.t(),
          substitutions: nil | SendGrid.Email.substitutions(),
          custom_args: nil | SendGrid.Email.custom_args(),
          send_at: nil | integer,
          headers: nil | [SendGrid.Email.header()]
        }

  @doc """
  Builds an an empty personalization to compose on.

  ## Examples

      alias SendGrid.Personalization

      Personalization.build()
      |> Personalization.add_to("test@email.com")

  """
  @spec build :: t
  def build do
    %Personalization{}
  end

  @doc """
  Sets the `to` field for the personalization.

  A to-name can be passed as the third parameter.

  ## Examples

      Personalization.add_to(%Personalization{}, "test@email.com")
      Personalization.add_to(%Personalization{}, "test@email.com", "John Doe")

  """
  @spec add_to(t, String.t()) :: t
  def add_to(%Personalization{to: to} = p, to_address) do
    addresses = add_address_to_list(to, to_address)
    %Personalization{p | to: addresses}
  end

  @spec add_to(t, String.t(), String.t()) :: t
  def add_to(%Personalization{to: to} = p, to_address, to_name) do
    addresses = add_address_to_list(to, to_address, to_name)
    %Personalization{p | to: addresses}
  end

  @doc """
  Add recipients to the `CC` address field.

  The cc-name can be specified as the third parameter.

  ## Examples

      Personalization.add_cc(%Personalization{}, "test@email.com")
      Personalization.add_cc(%Personalization{}, "test@email.com", "John Doe")

  """
  @spec add_cc(t, String.t()) :: t
  def add_cc(%Personalization{cc: cc} = p, cc_address) do
    addresses = add_address_to_list(cc, cc_address)
    %Personalization{p | cc: addresses}
  end

  @spec add_cc(Personalization.t(), String.t(), String.t()) :: t
  def add_cc(%Personalization{cc: cc} = p, cc_address, cc_name) do
    addresses = add_address_to_list(cc, cc_address, cc_name)
    %Personalization{p | cc: addresses}
  end

  @doc """
  Add recipients to the `BCC` address field.

  The bcc-name can be specified as the third parameter.

  ## Examples

      Personalization.add_bcc(%Personalization{}, "test@email.com")
      Personalization.add_bcc(%Personalization{}, "test@email.com", "John Doe")

  """
  @spec add_bcc(t, String.t()) :: t
  def add_bcc(%Personalization{bcc: bcc} = p, bcc_address) do
    addresses = add_address_to_list(bcc, bcc_address)
    %Personalization{p | bcc: addresses}
  end

  @spec add_bcc(t, String.t(), String.t()) :: t
  def add_bcc(%Personalization{bcc: bcc} = p, bcc_address, bcc_name) do
    addresses = add_address_to_list(bcc, bcc_address, bcc_name)
    %Personalization{p | bcc: addresses}
  end

  @doc """
  Sets the `subject` field for the personalization.

  ## Examples

      Personalization.put_subject(%Personalization{}, "Hello from Elixir")

  """
  @spec put_subject(t, String.t()) :: t
  def put_subject(%Personalization{} = p, subject) do
    %Personalization{p | subject: subject}
  end

  @doc """
  Sets a custom header.

  ## Examples

      Personalization.add_header(%Personalization{}, "HEADER_KEY", "HEADER_VALUE")

  """
  @spec add_header(t, String.t(), String.t()) :: t
  def add_header(%Personalization{headers: nil} = p, header_key, header_value) do
    %Personalization{p | headers: [{header_key, header_value}]}
  end

  def add_header(%Personalization{headers: [_ | _] = headers} = p, header_key, header_value) do
    headers = headers ++ [{header_key, header_value}]
    %Personalization{p | headers: headers}
  end

  @doc """
  Adds a substitution value to be used with a template.

  If a substitution for a given name is already set, it will be replaced when adding
  a substitution with the same name.

  ## Examples

      Personalization.add_substitution(%Personalization{}, "-sentIn-", "Elixir")

  """
  @spec add_substitution(t, String.t(), String.t()) :: t
  def add_substitution(
        %Personalization{substitutions: substitutions} = p,
        sub_name,
        sub_value
      ) do
    substitutions = Map.put(substitutions || %{}, sub_name, sub_value)
    %Personalization{p | substitutions: substitutions}
  end

  @doc """
  Adds a custom_arg value to the personalization.

  If an argument for a given name is already set, it will be replaced when adding
  a argument with the same name.

  ## Examples

      Personalization.add_custom_arg(%Personalization{}, "-sentIn-", "Elixir")

  """
  @spec add_custom_arg(t, String.t(), String.t()) :: t
  def add_custom_arg(%Personalization{custom_args: custom_args} = p, arg_name, arg_value) do
    custom_args = Map.put(custom_args || %{}, arg_name, arg_value)
    %Personalization{p | custom_args: custom_args}
  end

  @doc """
  Sets a future date of when to send the email.

  ## Examples

      Personalization.put_send_at(%Personalization{}, 1409348513)

  """
  @spec put_send_at(t, integer) :: t
  def put_send_at(%Personalization{} = p, send_at) do
    %Personalization{p | send_at: send_at}
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
end
