defmodule StarkInfra.AiAgent do
  alias __MODULE__, as: AiAgent
  alias StarkInfra.AiKnowledgeBase
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.JSON
  alias StarkInfra.Utils.Request
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups AiAgent related functions
  """

  @doc """
  An AiAgent is the configuration of an assistant: the model, the instructions, the knowledge it may consult and
  the voice it speaks with. The agent never changes during a conversation; the conversation lives in an AiChat
  and each turn is an AiMessage.
  When you initialize an AiAgent, the struct will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:name` [binary]: name of the agent. Between 1 and 100 characters. ex: "Support assistant"
    - `:model` [binary]: AI model the agent runs on. Options: "bender-1.0" for everyday conversations, "prime-1.0" for harder reasoning.

  ## Parameters (optional):
    - `:system_prompt` [binary, default nil]: instructions that define the agent's persona, tone and domain behavior. Up to 100000 characters. The API falls back to its default assistant prompt when omitted.
    - `:voice_id` [binary, default nil]: id of the AiVoice the agent speaks with. When set, every reply also carries a speech string ready to be sent to AiSpeech. The API does not check that the voice exists.
    - `:knowledge_base_ids` [list of binaries, default nil]: ids of up to 100 AiKnowledgeBases the agent retrieves from before answering. The API does not check that they exist.
    - `:metadata_schema` [map, default nil]: flat map whose keys are the fields the agent must extract on every reply. Each field takes a "type" (string, integer, number, boolean or array), an optional "description" of up to 2000 characters, an optional "enum" of up to 20 strings for string fields. The keys are yours and are sent exactly as written. ex: %{"order_id" => %{"type" => "string", "description" => "Order the customer mentions"}}

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the AiAgent is created. ex: "5656565656565656"
    - `:knowledge_bases` [list of AiKnowledgeBase structs]: the knowledge bases themselves. Only present when requested with expand: ["knowledgeBases"].
    - `:created` [DateTime]: creation datetime for the AiAgent. ex: ~U[2020-03-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the AiAgent. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :name,
    :model
  ]
  defstruct [
    :name,
    :model,
    :system_prompt,
    :voice_id,
    :knowledge_base_ids,
    :metadata_schema,
    :id,
    :knowledge_bases,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send an AiAgent struct for creation at the Stark Infra API.

  ## Parameters (required):
    - `:agent` [AiAgent struct]: AiAgent struct to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - AiAgent struct with updated attributes
  """
  @spec create(
    agent: AiAgent.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiAgent.t()} |
    {:error, [Error.t()]}
  def create(agent, options \\ []) do
    case Request.fetch(
      :post,
      path(),
      payload: agent |> payload() |> without_nils(),
      user: options[:user]
    ) do
      {:ok, response} -> {:ok, response |> JSON.decode!() |> Map.fetch!("agent") |> build()}
      {:error, errors} -> {:error, errors}
    end
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    agent: AiAgent.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(agent, options \\ []) do
    case create(agent, options) do
      {:ok, created} -> created
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  @doc """
  Receive a single AiAgent struct previously created in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [binary]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:expand` [list of binaries, default nil]: extra attributes to compute. Options: ["knowledgeBases"].
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.
  ## Return:
    - AiAgent struct with updated attributes
  """
  @spec get(
    id: binary,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiAgent.t()} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Rest.get_id(
      resource(),
      id,
      options
    )
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(
    id: binary,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(
      resource(),
      id,
      options
    )
  end

  @doc """
  Receive a stream of AiAgent structs previously created in the Stark Infra API.

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:expand` [list of binaries, default nil]: extra attributes to compute. Options: ["knowledgeBases"].
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of AiAgent structs with updated attributes
  """
  @spec query(
    limit: integer | nil,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    Enumerable.t()
  def query(options \\ []) do
    Rest.get_list(
      resource(),
      options
    )
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
    limit: integer | nil,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 AiAgent structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:expand` [list of binaries, default nil]: extra attributes to compute. Options: ["knowledgeBases"].
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - cursor to retrieve the next page of AiAgent structs, nil on the last page
    - list of AiAgent structs with updated attributes
  """
  @spec page(
    cursor: binary | nil,
    limit: integer | nil,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary | nil, [AiAgent.t()]}} |
    {:error, [Error.t()]}
  def page(options \\ []) do
    Rest.get_page(
      resource(),
      options
    )
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
    cursor: binary | nil,
    limit: integer | nil,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Update an AiAgent's parameters by passing its id. All six parameters are named in the request and the ones you do not give go as null:
  the API keeps what you do not send. To clear a value, send an empty one: "" for a text, [] for a list, %{} for the schema.

  ## Parameters (required):
    - `:id` [binary]: AiAgent unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:name` [binary, default nil]: new name for the agent. Between 1 and 100 characters.
    - `:model` [binary, default nil]: new AI model. Options: "bender-1.0", "prime-1.0"
    - `:system_prompt` [binary, default nil]: new instructions for the agent. Up to 100000 characters.
    - `:voice_id` [binary, default nil]: new AiVoice id.
    - `:knowledge_base_ids` [list of binaries, default nil]: the AiKnowledgeBase ids the agent should end up with. Replaces the current list as a whole.
    - `:metadata_schema` [map, default nil]: new schema of the structured data the agent must extract. The keys are yours and are sent exactly as written.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target AiAgent with updated attributes
  """
  @spec update(
    id: binary,
    name: binary | nil,
    model: binary | nil,
    system_prompt: binary | nil,
    voice_id: binary | nil,
    knowledge_base_ids: [binary] | nil,
    metadata_schema: map | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiAgent.t()} |
    {:error, [Error.t()]}
  def update(id, parameters \\ []) do
    parameters = Map.new(parameters)

    case Request.fetch(
      :patch,
      "#{path()}/#{id}",
      payload: payload(parameters),
      user: parameters[:user]
    ) do
      {:ok, response} -> {:ok, response |> JSON.decode!() |> Map.fetch!("agent") |> build()}
      {:error, errors} -> {:error, errors}
    end
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(
    id: binary,
    name: binary | nil,
    model: binary | nil,
    system_prompt: binary | nil,
    voice_id: binary | nil,
    knowledge_base_ids: [binary] | nil,
    metadata_schema: map | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def update!(id, parameters \\ []) do
    case update(id, parameters) do
      {:ok, updated} -> updated
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  @doc """
  Delete up to 100 AiAgents at once.

  ## Parameters (required):
    - `:ids` [list of binaries]: ids of the AiAgents to be deleted. Up to 100 ids. ex: ["5656565656565656", "4545454545454545"]

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of deleted AiAgent structs
  """
  @spec delete(
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [AiAgent.t()]} |
    {:error, [Error.t()]}
  def delete(ids, options \\ []) do
    case Request.fetch(
      :delete,
      path(),
      query: %{ids: ids},
      user: options[:user]
    ) do
      {:ok, response} -> {:ok, response |> JSON.decode!() |> Map.fetch!("agents") |> Enum.map(&build/1)}
      {:error, errors} -> {:error, errors}
    end
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def delete!(ids, options \\ []) do
    case delete(ids, options) do
      {:ok, deleted} -> deleted
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  @doc false
  def resource() do
    {
      "AiAgent",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %AiAgent{
      name: json[:name],
      model: json[:model],
      system_prompt: json[:system_prompt],
      voice_id: json[:voice_id],
      knowledge_base_ids: json[:knowledge_base_ids],
      metadata_schema: json[:metadata_schema],
      id: json[:id],
      knowledge_bases: json[:knowledge_bases] |> knowledge_bases(),
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end

  defp path() do
    {resource_name, _resource_maker} = resource()
    API.endpoint(resource_name)
  end

  defp payload(source) do
    %{
      "name" => Map.get(source, :name),
      "model" => Map.get(source, :model),
      "systemPrompt" => Map.get(source, :system_prompt),
      "voiceId" => Map.get(source, :voice_id),
      "knowledgeBaseIds" => Map.get(source, :knowledge_base_ids),
      "metadataSchema" => Map.get(source, :metadata_schema)
    }
  end

  defp without_nils(payload) do
    payload |> Enum.reject(fn {_key, value} -> is_nil(value) end) |> Map.new()
  end

  defp build(json) do
    API.from_api_json(json, &resource_maker/1)
  end

  defp knowledge_bases(nil), do: nil
  defp knowledge_bases(knowledge_bases), do: Enum.map(knowledge_bases, &knowledge_base/1)

  defp knowledge_base(%AiKnowledgeBase{} = knowledge_base), do: knowledge_base
  defp knowledge_base(json), do: API.from_api_json(json, &AiKnowledgeBase.resource_maker/1)
end
