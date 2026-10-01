defmodule StarkInfra.AiChat do
  alias __MODULE__, as: AiChat
  alias StarkInfra.Utils.AiApi
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.Request
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups AiChat related functions
  """

  @creatable [:agent_id, :title]

  @doc """
  An AiChat is one conversation thread with an AiAgent and holds the history. Each turn is an AiMessage.
  When you initialize an AiChat, the struct will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:agent_id` [binary]: id of the AiAgent that will answer in this chat. ex: "5656565656565656"

  ## Parameters (optional):
    - `:title` [binary, default nil]: title of the conversation. Up to 100 characters. When omitted, the first message posted to the chat generates one.

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the AiChat is created. ex: "5656565656565656"
    - `:agent_name` [binary]: name of the agent. Only present when requested with expand: [:agent_name].
    - `:updated` [DateTime]: latest update datetime for the AiChat. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :agent_id
  ]
  defstruct [
    :agent_id,
    :title,
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
    Request.fetch(
      :post,
      path(),
      # the API answers 400 to id, agent_name and updated, which a struct returned by get/create carries
      payload: AiApi.payload(chat, @creatable),
      user: options[:user]
    )
    |> AiApi.single("chat", &resource_maker/1)
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    chat: AiChat.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(chat, options \\ []) do
    create(chat, options) |> AiApi.unwrap!()
  end

  @doc """
  Receive a single AiChat struct previously created in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [binary]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:fields` [list of atoms, default nil]: attributes to keep in the response. ex: [:id, :title]
    - `:expand` [list of atoms, default nil]: extra attributes to compute. Options: [:agent_name]. When fields is also given, the expanded attribute must be listed there too.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - AiChat struct with updated attributes
  """
  @spec get(
    id: binary,
    fields: [atom] | nil,
    expand: [atom] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiChat.t()} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Request.fetch(
      :get,
      "#{path()}/#{id}",
      query: AiApi.fields_and_expand(options),
      user: options[:user]
    )
    |> AiApi.single("chat", &resource_maker/1)
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
  Receive a stream of AiChat structs previously created in the Stark Infra API.
  This route is not paginated and rejects limit, cursor and every filter, so they are not options here.

  ## Options:
    - `:fields` [list of atoms, default nil]: attributes to keep in the response. ex: [:id, :title]
    - `:expand` [list of atoms, default nil]: extra attributes to compute. Options: [:agent_name]. When fields is also given, the expanded attribute must be listed there too.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of AiChat structs with updated attributes
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
  Update an AiChat's parameters by passing its id. Only the parameters you give are changed.

  ## Parameters (required):
    - `:id` [binary]: AiChat unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:title` [binary, default nil]: new title for the conversation. Up to 100 characters.
    - `:agent_id` [binary, default nil]: id of the AiAgent that should answer from now on.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target AiChat with updated attributes
  """
  @spec update(
    id: binary,
    title: binary | nil,
    agent_id: binary | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiChat.t()} |
    {:error, [Error.t()]}
  def update(id, parameters \\ []) do
    # with no parameter at all the body is still an empty JSON object: the API answers 400 to a list
    Request.fetch(
      :patch,
      "#{path()}/#{id}",
      payload: parameters |> Map.new() |> AiApi.payload(@creatable),
      user: parameters[:user]
    )
    |> AiApi.single("chat", &resource_maker/1)
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(
    id: binary,
    title: binary | nil,
    agent_id: binary | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def update!(id, parameters \\ []) do
    update(id, parameters) |> AiApi.unwrap!()
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
    # ids travel in the query string: this route takes no body
    Request.fetch(
      :delete,
      path(),
      query: %{ids: ids},
      user: options[:user]
    )
    |> AiApi.many("chats", &resource_maker/1)
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
      "AiChat",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %AiChat{
      agent_id: json[:agent_id],
      title: json[:title],
      id: json[:id],
      agent_name: json[:agent_name],
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
    |> AiApi.many("chats", &resource_maker/1)
  end
end
