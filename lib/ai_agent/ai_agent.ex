defmodule StarkInfra.AiAgent do
  alias __MODULE__, as: AiAgent
  alias StarkInfra.AiKnowledgeBase
  alias StarkInfra.Utils.AiApi
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.Request
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups AiAgent related functions
  """

  @creatable [:name, :model, :system_prompt, :voice_id, :knowledge_base_ids, :metadata_schema]

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
    - `:knowledge_bases` [list of AiKnowledgeBase structs]: the knowledge bases themselves. Only present when requested with expand: [:knowledge_bases].
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
    Request.fetch(
      :post,
      path(),
      # the API answers 400 to id, knowledge_bases, created and updated, which a struct returned by get/create carries
      payload: agent |> AiApi.payload(@creatable) |> without_empty_voice(),
      user: options[:user]
    )
    |> AiApi.single("agent", &resource_maker/1)
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    agent: AiAgent.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(agent, options \\ []) do
    create(agent, options) |> AiApi.unwrap!()
  end

  @doc """
  Receive a single AiAgent struct previously created in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [binary]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:fields` [list of atoms, default nil]: attributes to keep in the response. ex: [:id, :name]
    - `:expand` [list of atoms, default nil]: extra attributes to compute. Options: [:knowledge_bases]. When fields is also given, the expanded attribute must be listed there too.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - AiAgent struct with updated attributes
  """
  @spec get(
    id: binary,
    fields: [atom] | nil,
    expand: [atom] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiAgent.t()} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Request.fetch(
      :get,
      "#{path()}/#{id}",
      query: AiApi.fields_and_expand(options),
      user: options[:user]
    )
    |> AiApi.single("agent", &resource_maker/1)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(
    id: binary,
    fields: [atom] | nil,
    expand: [atom] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def get!(id, options \\ []) do
    get(id, options) |> AiApi.unwrap!()
  end

  @doc """
  Receive a stream of AiAgent structs previously created in the Stark Infra API.
  This route is not paginated and rejects limit, cursor and every filter, so they are not options here.

  ## Options:
    - `:fields` [list of atoms, default nil]: attributes to keep in the response. ex: [:id, :name]
    - `:expand` [list of atoms, default nil]: extra attributes to compute. Options: [:knowledge_bases]. When fields is also given, the expanded attribute must be listed there too.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of AiAgent structs with updated attributes
  """
  @spec query(
    fields: [atom] | nil,
    expand: [atom] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: Enumerable.t()
  def query(options \\ []) do
    AiApi.stream(fn -> list_result(options) end)
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
    fields: [atom] | nil,
    expand: [atom] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def query!(options \\ []) do
    AiApi.stream!(fn -> list_result(options) end)
  end

  @doc """
  Update an AiAgent's parameters by passing its id. Only the parameters you give are changed.
  The API replaces the knowledge base list with whatever the request carries and clears it when the request
  carries none, so when knowledge_base_ids is not given this function reads the agent first and sends its
  current list back. Pass an empty list to clear the knowledge bases on purpose.
  The read and the update are two requests, so a knowledge base change made by someone else between them is overwritten.

  ## Parameters (required):
    - `:id` [binary]: AiAgent unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:name` [binary, default nil]: new name for the agent. Between 1 and 100 characters.
    - `:model` [binary, default nil]: new AI model. Options: "bender-1.0", "prime-1.0"
    - `:system_prompt` [binary, default nil]: new instructions for the agent. Up to 100000 characters.
    - `:voice_id` [binary, default nil]: new AiVoice id.
    - `:knowledge_base_ids` [list of binaries, default nil]: the AiKnowledgeBase ids the agent should end up with. Replaces the current list.
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

    with {:ok, knowledge_base_ids} <- current_knowledge_base_ids(id, parameters) do
      Request.fetch(
        :patch,
        "#{path()}/#{id}",
        payload: parameters |> Map.put(:knowledge_base_ids, knowledge_base_ids) |> AiApi.payload(@creatable) |> without_empty_voice(),
        user: parameters[:user]
      )
      |> AiApi.single("agent", &resource_maker/1)
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
    update(id, parameters) |> AiApi.unwrap!()
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
    # ids travel in the query string: this route takes no body
    Request.fetch(
      :delete,
      path(),
      query: %{ids: ids},
      user: options[:user]
    )
    |> AiApi.many("agents", &resource_maker/1)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def delete!(ids, options \\ []) do
    delete(ids, options) |> AiApi.unwrap!()
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

  defp list_result(options) do
    Request.fetch(
      :get,
      path(),
      query: AiApi.fields_and_expand(options),
      user: options[:user]
    )
    |> AiApi.many("agents", &resource_maker/1)
  end

  defp current_knowledge_base_ids(id, parameters) do
    case parameters[:knowledge_base_ids] do
      nil -> read_knowledge_base_ids(id, parameters[:user])
      knowledge_base_ids -> {:ok, knowledge_base_ids}
    end
  end

  defp read_knowledge_base_ids(id, user) do
    case get(id, fields: [:knowledge_base_ids], user: user) do
      {:ok, agent} -> {:ok, agent.knowledge_base_ids}
      {:error, errors} -> {:error, errors}
    end
  end

  defp knowledge_bases(nil), do: nil
  defp knowledge_bases(knowledge_bases), do: Enum.map(knowledge_bases, &knowledge_base/1)

  defp knowledge_base(%AiKnowledgeBase{} = knowledge_base), do: knowledge_base
  defp knowledge_base(json), do: AiApi.build(json, &AiKnowledgeBase.resource_maker/1)

  # an agent without a voice comes back with voice_id "", which the API rejects, so "" is treated as not given
  defp without_empty_voice(%{"voiceId" => ""} = payload), do: Map.delete(payload, "voiceId")
  defp without_empty_voice(payload), do: payload
end
