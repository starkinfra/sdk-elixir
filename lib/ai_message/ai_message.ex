defmodule StarkInfra.AiMessage do
  alias __MODULE__, as: AiMessage
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.JSON
  alias StarkInfra.Utils.Request
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups AiMessage related functions
  """

  @doc """
  An AiMessage is a single turn of an AiChat. You post what the user said and the same call returns the user's
  message and the agent's answer.
  When you initialize an AiMessage, the struct will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the user's message and the agent's answer.

  ## Parameters (required):
    - `:chat_id` [binary]: id of the AiChat to post to. ex: "5656565656565656"
    - `:text` [binary]: content of the user's message. Between 1 and 50000 characters. ex: "What is the status of my order?"

  ## Parameters (optional):
    - `:model` [binary, default nil]: AI model to use for this turn only. Options: "bender-1.0", "prime-1.0". The API defaults to the agent's own model.

  ## Attributes (return-only):
    - `:id` [binary]: unique id of the AiMessage. ex: "5656565656565656"
    - `:sender` [binary]: who wrote the message. Options: "user", "system". The agent's answers are sent by "system".
    - `:speech` [binary]: version of the text written to be heard rather than read, ready to be sent to AiSpeech. Only filled when the agent has a voice.
    - `:metadata` [map]: structured data the agent extracted, shaped by the agent's metadata_schema. The keys are the agent's, exactly as it declared them.
    - `:chat_name` [binary]: title of the chat. Only present when create is called with expand: ["chatName"].
    - `:created` [DateTime]: creation datetime for the AiMessage. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :chat_id,
    :text
  ]
  defstruct [
    :chat_id,
    :text,
    :model,
    :id,
    :sender,
    :speech,
    :metadata,
    :chat_name,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Post the user's message to an AiChat. The call waits for the agent, which takes a few seconds, and returns both messages.

  ## Parameters (required):
    - `:message` [AiMessage struct]: AiMessage struct with chat_id and text, to be created in the API.

  ## Options:
    - `:expand` [list of binaries, default nil]: extra attributes to compute. Options: ["chatName"], which returns the chat title on every message, useful on the first turn, when the title is generated.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list with the user's AiMessage and the agent's AiMessage
  """
  @spec create(
    message: AiMessage.t() | map(),
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [AiMessage.t()]} |
    {:error, [Error.t()]}
  def create(message, options \\ []) do
    case Request.fetch(
      :post,
      path(),
      payload: message |> payload() |> without_nils(),
      query: %{expand: options[:expand]},
      user: options[:user]
    ) do
      {:ok, response} -> {:ok, created_messages(response)}
      {:error, errors} -> {:error, errors}
    end
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    message: AiMessage.t() | map(),
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(message, options \\ []) do
    case create(message, options) do
      {:ok, created} -> created
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  @doc """
  Receive a stream of AiMessage structs previously created in the Stark Infra API.

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:chat_id` [binary, default nil]: id of the AiChat whose messages you want. When omitted, the messages of the whole workspace are returned. ex: "5656565656565656"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of AiMessage structs with updated attributes
  """
  @spec query(
    limit: integer | nil,
    chat_id: binary | nil,
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
    chat_id: binary | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 AiMessage structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:chat_id` [binary, default nil]: id of the AiChat whose messages you want. When omitted, the messages of the whole workspace are returned. ex: "5656565656565656"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - cursor to retrieve the next page of AiMessage structs, nil on the last page
    - list of AiMessage structs with updated attributes
  """
  @spec page(
    cursor: binary | nil,
    limit: integer | nil,
    chat_id: binary | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary | nil, [AiMessage.t()]}} |
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
    chat_id: binary | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc false
  def resource() do
    {
      "AiMessage",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %AiMessage{
      chat_id: json[:chat_id],
      text: json[:text],
      model: json[:model],
      id: json[:id],
      sender: json[:sender],
      speech: json[:speech],
      metadata: json[:metadata],
      chat_name: json[:chat_name],
      created: json[:created] |> Check.datetime()
    }
  end

  defp path() do
    {resource_name, _resource_maker} = resource()
    API.endpoint(resource_name)
  end

  defp payload(source) do
    %{
      "chatId" => Map.get(source, :chat_id),
      "text" => Map.get(source, :text),
      "model" => Map.get(source, :model)
    }
  end

  defp without_nils(payload) do
    payload |> Enum.reject(fn {_key, value} -> is_nil(value) end) |> Map.new()
  end

  defp created_messages(response) do
    content = JSON.decode!(response)
    Enum.map(content["messages"], &%{build(&1) | chat_name: content["chatName"]})
  end

  defp build(json) do
    API.from_api_json(json, &resource_maker/1)
  end
end
