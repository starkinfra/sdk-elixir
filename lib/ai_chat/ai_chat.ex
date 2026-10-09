defmodule StarkInfra.AiChat do
  alias __MODULE__, as: AiChat
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.JSON
  alias StarkInfra.Utils.Request
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups AiChat related functions
  """

  @doc """
  An AiChat is one conversation thread with an AiAgent and holds the history. Each turn is an AiMessage.
  When you initialize an AiChat, the struct will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:agent_id` [binary]: id of the AiAgent that will answer in this chat. ex: "5656565656565656"

  ## Parameters (optional):
    - `:title` [binary, default nil]: title of the conversation. Up to 100 characters. When omitted, the first message posted to the chat generates one.
    - `:tags` [list of binaries, default nil]: list of up to 100 strings, each up to 100 characters and stored in lowercase, to find the chat later. ex: ["customer-123", "whatsapp"]
    - `:context` [map, default nil]: data about the person on the other side of the chat that the agent reads before every reply. Up to 16384 bytes, treated as reference data and never as instructions. The keys are yours and are sent exactly as written. Keys whose value is nil are left out by the API. ex: %{"name" => "Ana", "balance" => 1520.33}

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the AiChat is created. ex: "5656565656565656"
    - `:agent_name` [binary]: name of the agent. Only present when requested with expand: ["agentName"].
    - `:updated` [DateTime]: latest update datetime for the AiChat. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :agent_id
  ]
  defstruct [
    :agent_id,
    :title,
    :tags,
    :context,
    :id,
    :agent_name,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send an AiChat struct for creation at the Stark Infra API.

  ## Parameters (required):
    - `:chat` [AiChat struct]: AiChat struct to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - AiChat struct with updated attributes
  """
  @spec create(
    chat: AiChat.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiChat.t()} |
    {:error, [Error.t()]}
  def create(chat, options \\ []) do
    case Request.fetch(
      :post,
      path(),
      payload: chat |> payload() |> without_nils(),
      user: options[:user]
    ) do
      {:ok, response} -> {:ok, response |> JSON.decode!() |> Map.fetch!("chat") |> build()}
      {:error, errors} -> {:error, errors}
    end
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    chat: AiChat.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(chat, options \\ []) do
    case create(chat, options) do
      {:ok, created} -> created
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  @doc """
  Receive a single AiChat struct previously created in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [binary]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:expand` [list of binaries, default nil]: extra attributes to compute. Options: ["agentName"].
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.
  ## Return:
    - AiChat struct with updated attributes
  """
  @spec get(
    id: binary,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiChat.t()} |
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
  Receive a stream of AiChat structs previously created in the Stark Infra API.

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:expand` [list of binaries, default nil]: extra attributes to compute. Options: ["agentName"].
    - `:tags` [list of binaries, default nil]: up to 30 tags. Retrieves the chats that have any of them. ex: ["customer-123"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of AiChat structs with updated attributes
  """
  @spec query(
    limit: integer | nil,
    expand: [binary] | nil,
    tags: [binary] | nil,
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
    tags: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 AiChat structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:expand` [list of binaries, default nil]: extra attributes to compute. Options: ["agentName"].
    - `:tags` [list of binaries, default nil]: up to 30 tags. Retrieves the chats that have any of them. ex: ["customer-123"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - cursor to retrieve the next page of AiChat structs, nil on the last page
    - list of AiChat structs with updated attributes
  """
  @spec page(
    cursor: binary | nil,
    limit: integer | nil,
    expand: [binary] | nil,
    tags: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary | nil, [AiChat.t()]}} |
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
    tags: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Update an AiChat's parameters by passing its id. All four parameters are named in the request and the ones you do not give go as null:
  the API keeps what you do not send. To clear a value, send an empty one: "" for the title, [] for the tags, %{} for the context.

  ## Parameters (required):
    - `:id` [binary]: AiChat unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:title` [binary, default nil]: new title for the conversation. Up to 100 characters.
    - `:agent_id` [binary, default nil]: id of the AiAgent that should answer from now on.
    - `:tags` [list of binaries, default nil]: new list of up to 100 strings. Replaces the current list as a whole; an empty list removes them.
    - `:context` [map, default nil]: new data about the person on the other side of the chat. Replaces the current map as a whole and is used from the next message on; an empty map removes it. The keys are yours and are sent exactly as written.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target AiChat with updated attributes
  """
  @spec update(
    id: binary,
    title: binary | nil,
    agent_id: binary | nil,
    tags: [binary] | nil,
    context: map | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiChat.t()} |
    {:error, [Error.t()]}
  def update(id, parameters \\ []) do
    parameters = Map.new(parameters)

    case Request.fetch(
      :patch,
      "#{path()}/#{id}",
      payload: payload(parameters),
      user: parameters[:user]
    ) do
      {:ok, response} -> {:ok, response |> JSON.decode!() |> Map.fetch!("chat") |> build()}
      {:error, errors} -> {:error, errors}
    end
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(
    id: binary,
    title: binary | nil,
    agent_id: binary | nil,
    tags: [binary] | nil,
    context: map | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def update!(id, parameters \\ []) do
    case update(id, parameters) do
      {:ok, updated} -> updated
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  @doc """
  Delete up to 100 AiChats at once, with their messages.

  ## Parameters (required):
    - `:ids` [list of binaries]: ids of the AiChats to be deleted. Up to 100 ids. ex: ["5656565656565656", "4545454545454545"]

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of deleted AiChat structs
  """
  @spec delete(
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [AiChat.t()]} |
    {:error, [Error.t()]}
  def delete(ids, options \\ []) do
    case Request.fetch(
      :delete,
      path(),
      query: %{ids: ids},
      user: options[:user]
    ) do
      {:ok, response} -> {:ok, response |> JSON.decode!() |> Map.fetch!("chats") |> Enum.map(&build/1)}
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
      "AiChat",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %AiChat{
      agent_id: json[:agent_id],
      title: json[:title],
      tags: json[:tags],
      context: json[:context],
      id: json[:id],
      agent_name: json[:agent_name],
      updated: json[:updated] |> Check.datetime()
    }
  end

  defp path() do
    {resource_name, _resource_maker} = resource()
    API.endpoint(resource_name)
  end

  defp payload(source) do
    %{
      "agentId" => Map.get(source, :agent_id),
      "title" => Map.get(source, :title),
      "tags" => Map.get(source, :tags),
      "context" => Map.get(source, :context)
    }
  end

  defp without_nils(payload) do
    payload |> Enum.reject(fn {_key, value} -> is_nil(value) end) |> Map.new()
  end

  defp build(json) do
    API.from_api_json(json, &resource_maker/1)
  end
end
