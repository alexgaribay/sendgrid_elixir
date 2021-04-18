defmodule SendGrid.Templates do
  alias SendGrid.Template
  @base_api_url "/v3/templates"
  @valid_generations [:legacy, :dynamic]
  @success_codes [200,201,202,203,204]

  #----------------------------------------
  # Result Set
  #----------------------------------------
  defstruct [
    templates: [],
    metadata: nil,
  ]

  @type t :: %SendGrid.Templates{
               templates: [SendGrid.Template.t],
               metadata: SendGrid.MetaData.t | nil,
             }

  @spec new(SendGrid.Response.t, SendGrid.query()) :: Templates.t | {:error, [String.t]} | {:error, String.t}
  def new(%SendGrid.Response{body: %{"_metadata" => metadata, "result" => result}}, options) do
    %__MODULE__{
      templates: Enum.map(result, &(SendGrid.Template.new(&1, :json))),
      metadata: SendGrid.MetaData.new(metadata, options, :json)
    }
  end
  def new(%SendGrid.Response{body: %{"templates" => templates}}, options) do
    %__MODULE__{
      templates: Enum.map(templates, &(SendGrid.Template.new(&1, :json))),
      metadata: SendGrid.MetaData.new(%{}, options, :json)
    }
  end
  def new(_), do: {:error, "#{__MODULE__} Unsupported Initializer"}

  #----------------------------------------
  # Pagination
  #----------------------------------------
  @spec next(SendGrid.Templates.t, SendGrid.query()) :: Templates.t | {:error, [String.t]} | {:error, String.t}
  def next(self, options \\ [])
  def next(%SendGrid.Templates{metadata: %SendGrid.MetaData{next: nil}}, options) do
    nil
  end
  def next(%SendGrid.Templates{} = self, options) do
    # Note only api_key may be changed when calling next
    options = cond do
                api_key = options[:api_key] -> Keyword.put(self.metadata.options || [], :api_key, api_key)
                :else -> self.metadata.options || []
              end
    options = cond do
                query = options[:query] ->
                  query = Keyword.put(query, :page_token, self.metadata.next)
                  Keyword.put(options, :query, query)
                :else ->
                  Keyword.put(options, :query, [page_token: self.metadata.next])
              end
    fetch = SendGrid.get(@base_api_url, options)
    case fetch do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        __MODULE__.new(response, options)
      { :ok, %SendGrid.Response{ body: body } } ->
        { :error, body["errors"] || body["error"] }
      _ ->
        { :error, "Unable to communicate with SendGrid API." }
    end
  end

  #----------------------------------------
  # CRUD
  #----------------------------------------
  @spec get(String.t, SendGrid.query()) :: SendGrid.DynamicTemplate.t | SendGrid.LegacyTemplate.t | {:error, [String.t]} | {:error, String.t}
  def get(identifier, options \\ []) do
    options = patch_options(options)
    case SendGrid.get(@base_api_url <> "/#{identifier}", options) do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        SendGrid.Template.new(response.body, :json)
      { :ok, %SendGrid.Response{ body: body } } -> { :error, body["errors"] || body["error"] }
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end

  @spec update(SendGrid.LegacyTemplate.t | SendGrid.DynamicTemplate.t, SendGrid.query()) :: SendGrid.DynamicTemplate.t | SendGrid.LegacyTemplate.t | {:error, [String.t]} | {:error, String.t}
  def update(template, options \\ [])
  def update(%SendGrid.LegacyTemplate{} = template, options) do
    options = patch_options(options)
    case SendGrid.patch(@base_api_url <> "/#{template.id}", template, options) do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        SendGrid.Template.new(response.body, :json)
      { :ok, %SendGrid.Response{ body: body } } ->
        { :error, body["errors"] || body["error"] }
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end
  def update(%SendGrid.DynamicTemplate{} = template, options) do
    options = patch_options(options)
    case SendGrid.patch(@base_api_url <> "/#{template.id}", template, options) do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        SendGrid.Template.new(response.body, :json)
      { :ok, %SendGrid.Response{ body: body } } ->
        { :error, body["errors"] || body["error"] }
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end

  @spec create(SendGrid.LegacyTemplate.t | SendGrid.DynamicTemplate.t, SendGrid.query()) :: SendGrid.DynamicTemplate.t | SendGrid.LegacyTemplate.t | {:error, [String.t]} | {:error, String.t}
  def create(template, options \\ [])
  def create(%SendGrid.LegacyTemplate{} = template, options) do
    options = patch_options(options)
    case SendGrid.post(@base_api_url, template, options) do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        SendGrid.Template.new(response.body, :json)
      { :ok, %SendGrid.Response{ body: body }} ->
        { :error, body["errors"] || body["error"] }
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end
  def create(%SendGrid.DynamicTemplate{} = template, options) do
    options = patch_options(options)
    case SendGrid.post(@base_api_url, template, options) do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        SendGrid.Template.new(response.body, :json)
      { :ok, %SendGrid.Response{ body: body }} ->
        { :error, body["errors"] || body["error"] }
      _ -> { :error, "Unable to communicate with SendGrid API." }
    end
  end

  @spec delete(String.t | SendGrid.DynamicTemplate.t | Sendgrid.LegacyTemplate.t, SendGrid.query()) :: :ok | {:error, [String.t]} | {:error, String.t}
  def delete(template, options \\ [])
  def delete(%SendGrid.LegacyTemplate{id: id}, options) do
    delete(id, options)
  end
  def delete(%SendGrid.DynamicTemplate{id: id}, options) do
    delete(id, options)
  end
  def delete(identifier, options) when is_bitstring(identifier) do
    options = patch_options(options)
    case SendGrid.delete(@base_api_url <> "/#{identifier}", options) do
      { :ok, %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        :ok
      { :ok, %SendGrid.Response{ body: body } } ->
        { :error, body["errors"] || body["error"] }
      _ ->
        { :error, "Unable to communicate with SendGrid API." }
    end
  end

  @spec list(SendGrid.query()) :: SendGrid.Templates.t | {:error, [String.t]} | {:error, String.t}
  def list(options \\ []) do
    options = patch_options(options)
    fetch = SendGrid.get(@base_api_url, options)
    case fetch do
      { :ok, response = %SendGrid.Response{ status: status_code } } when status_code in @success_codes ->
        __MODULE__.new(response, options)
      { :ok, %SendGrid.Response{ body: body } } ->
        { :error, body["errors"] || body["error"] }
      _ ->
        { :error, "Unable to communicate with SendGrid API." }
    end
  end

  #----------------------------------------
  # Support
  #----------------------------------------
  @doc """
    Param injector does not handle list data, overriding here to allow user to pass in array or desired generations.
  """
  @spec patch_options(SendGrid.query()) :: SendGrid.query()
  def patch_options(options \\ []) do
    case options[:query][:generations] do
      v when is_list(v) ->
        generations = v
                      |> Enum.map(&("#{&1}"))
                      |> Enum.join(",")
        put_in(options, [:query, :generations], generations)
      v when is_atom(v) -> options
      v when is_bitstring(v) -> options
      _else -> options
    end
  end

end