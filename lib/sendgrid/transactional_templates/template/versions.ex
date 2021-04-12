defmodule SendGrid.Template.Versions do
  alias SendGrid.Template.Version

  @success_codes [200,201,202,203,204]

  @spec activate(Version.t) :: Version.t | {:error, [String.t]} | {:error, String.t}
  def activate(%Version{} = version) do
    case SendGrid.post(base_url(version.template_id, version.id) <> "/activate", version, []) do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        Version.new(response.body, :json)
      { :ok, %SendGrid.Response{ body: body } } -> { :error, body["errors"]  || body["error"]}
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end

  @spec get(String.t, String.t) :: Version.t | {:error, [String.t]} | {:error, String.t}
  def get(template, version) do
    case SendGrid.get(base_url(template,version), []) do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        Version.new(response.body, :json)
      { :ok, %SendGrid.Response{ body: body } } ->
        { :error, body["errors"] || body["error"] }
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end

  @spec update(Version.t) :: Version.t | {:error, [String.t]} | {:error, String.t}
  def update(%Version{} = version) do
    case SendGrid.patch(base_url(version.template_id, version.id), version, []) do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        response = Version.new(response.body, :json)
        put_in(response, [Access.key(:template_id)], version.template_id)
      { :ok, %SendGrid.Response{ body: body } } -> { :error, body["errors"] || body["error"] }
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end

  @spec create(Version.t) :: Version.t | {:error, [String.t]} | {:error, String.t}
  def create(%Version{} = version) do
    case SendGrid.post(base_url(version.template_id), version, []) do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        response = Version.new(response.body, :json)
        if response.id != nil do
          get(version.template_id, response.id)
        else
          {:error, :post_create_fetch_failure}
        end

      { :ok, %SendGrid.Response{ body: body } } -> { :error, body["errors"] || body["error"]}
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end

  @spec delete(Version.t) :: :ok | {:error, [String.t]} | {:error, String.t}
  def delete(%Version{} = version) do
    case SendGrid.delete(base_url(version.template_id, version.id), []) do
      { :ok, %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        :ok
      { :ok, %SendGrid.Response{ body: body } } -> { :error, body["errors"] || body["error"] }
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end

  defp base_url(template) do
    "/v3/templates/#{template}/versions"
  end

  defp base_url(template, version) do
    "/v3/templates/#{template}/versions/#{version}"
  end

end
