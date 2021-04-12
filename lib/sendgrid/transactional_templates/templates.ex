defmodule SendGrid.Templates do
  alias SendGrid.Template
  @base_api_url "/v3/templates"

  @success_codes [200,201,202,203,204]

  @spec get(String.t) :: Template.t | {:error, [String.t]} | {:error, String.t}
  def get(identifier) do
    case SendGrid.get(@base_api_url <> "/#{identifier}", []) do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        SendGrid.Template.new(response.body, :json)
      { :ok, %SendGrid.Response{ body: body } } -> { :error, body["errors"] || body["error"] }
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end

  @spec update(Template.t) :: Template.t | {:error, [String.t]} | {:error, String.t}
  def update(%Template{} = template) do
    case SendGrid.patch(@base_api_url <> "/#{template.id}", template, []) do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        SendGrid.Template.new(response.body, :json)
      { :ok, %SendGrid.Response{ body: body } } ->
        { :error, body["errors"] || body["error"] }
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end

  @spec create(Template.t) :: Template.t | {:error, [String.t]} | {:error, String.t}
  def create(%Template{} = template) do
    case SendGrid.post(@base_api_url, template, []) do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        SendGrid.Template.new(response.body, :json)
      { :ok, %SendGrid.Response{ body: body }} ->
        { :error, body["errors"] || body["error"] }
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end

  @spec delete(Template.t) :: :ok | {:error, [String.t]} | {:error, String.t}
  def delete(%Template{} = template) do
    delete(template.id)
  end

  @spec delete(String.t) :: :ok | {:error, [String.t]} | {:error, String.t}
  def delete(identifier) when is_bitstring(identifier) do
    case SendGrid.delete(@base_api_url <> "/#{identifier}", []) do
      { :ok, %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        :ok
      { :ok, %SendGrid.Response{ body: body } } ->
        { :error, body["errors"] || body["error"] }
      _ ->
        { :error, "Unable to communicate with SendGrid API." }
    end
  end

  @spec list() :: [SendGrid.Template.t] | {:error, [String.t]} | {:error, String.t}
  def list() do
    fetch = SendGrid.get(@base_api_url, [])
    case fetch do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        for template <- response.body["templates"] do
          SendGrid.Template.new(template, :json)
        end
      { :ok, %SendGrid.Response{ body: body } } ->
        { :error, body["errors"] || body["error"] }
      _ ->
        { :error, "Unable to communicate with SendGrid API." }
    end
  end

end
