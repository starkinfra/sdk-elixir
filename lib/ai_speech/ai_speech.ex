defmodule StarkInfra.AiSpeech do
  alias __MODULE__, as: AiSpeech
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.JSON
  alias StarkInfra.Utils.Querystream
  alias StarkInfra.Utils.Request
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups AiSpeech related functions
  """

  @doc """
  An AiSpeech is one text read out loud by an AiVoice. The speech is synthesized when it is created and comes
  back as a base64 MP3 in the audio attribute.
  When you initialize an AiSpeech, the struct will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:voice_id` [binary]: id of the AiVoice that should read the text. Only a voice in "success" can speak. ex: "5656565656565656"
    - `:text` [binary]: text to read out loud. Between 1 and 100000 characters. ex: "Hello, how can I help you?"

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the AiSpeech is created. ex: "5656565656565656"
    - `:status` [binary]: current status of the speech. Options: "processing", "success", "failed"
    - `:audio` [binary]: base64-encoded MP3 of the speech. Left out of query and page results; get returns it.
    - `:voice_name` [binary]: name of the voice. Only present when requested with expand: ["voiceName"].
    - `:errors` [list of binaries]: reasons the synthesis failed. Empty when it worked.
    - `:created` [DateTime]: creation datetime for the AiSpeech. ex: ~U[2020-03-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the AiSpeech. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :voice_id,
    :text
  ]
  defstruct [
    :voice_id,
    :text,
    :id,
    :status,
    :audio,
    :voice_name,
    :errors,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send an AiSpeech struct for creation at the Stark Infra API. The audio is synthesized during the call.

  ## Parameters (required):
    - `:speech` [AiSpeech struct]: AiSpeech struct to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - AiSpeech struct with updated attributes
  """
  @spec create(
    speech: AiSpeech.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiSpeech.t()} |
    {:error, [Error.t()]}
  def create(speech, options \\ []) do
    Rest.post_single(
      resource(),
      speech,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    speech: AiSpeech.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(speech, options \\ []) do
    Rest.post_single!(
      resource(),
      speech,
      options
    )
  end

  @doc """
  Receive a single AiSpeech struct previously created in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [binary]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:expand` [list of binaries, default nil]: extra attributes to compute. Options: ["voiceName"].
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - AiSpeech struct with updated attributes
  """
  @spec get(
    id: binary,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiSpeech.t()} |
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
  Receive a stream of AiSpeech structs previously created in the Stark Infra API. The audio is left out of the results.

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:expand` [list of binaries, default nil]: extra attributes to compute. Options: ["voiceName"].
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of AiSpeech structs with updated attributes
  """
  @spec query(
    limit: integer | nil,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    Enumerable.t()
  def query(options \\ []) do
    Stream.resource(
      fn -> start_query(options) end,
      fn pid ->
        case Querystream.get(pid) do
          :halt -> {:halt, pid}
          {:ok, element} -> {[{:ok, build(element)}], pid}
          {:error, errors} -> {[{:error, errors}], pid}
        end
      end,
      fn _pid -> nil end
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
    options
    |> query()
    |> Stream.map(fn
      {:ok, speech} -> speech
      {:error, errors} -> raise API.errors_to_string(errors)
    end)
  end

  @doc """
  Receive a list of up to 100 AiSpeech structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:expand` [list of binaries, default nil]: extra attributes to compute. Options: ["voiceName"].
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - cursor to retrieve the next page of AiSpeech structs, nil on the last page
    - list of AiSpeech structs with updated attributes
  """
  @spec page(
    cursor: binary | nil,
    limit: integer | nil,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary | nil, [AiSpeech.t()]}} |
    {:error, [Error.t()]}
  def page(options \\ []) do
    case Request.fetch(
      :get,
      path(),
      query: options |> Map.new() |> Map.delete(:user),
      user: options[:user]
    ) do
      {:ok, response} -> {:ok, page_response(response)}
      {:error, errors} -> {:error, errors}
    end
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
    case page(options) do
      {:ok, result} -> result
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  @doc false
  def resource() do
    {
      "AiSpeech",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %AiSpeech{
      voice_id: json[:voice_id],
      text: json[:text],
      id: json[:id],
      status: json[:status],
      audio: json[:audio],
      voice_name: json[:voice_name],
      errors: json[:errors],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end

  defp path() do
    {resource_name, _resource_maker} = resource()
    API.endpoint(resource_name)
  end

  defp start_query(options) do
    user = options[:user]
    query = options |> Map.new() |> Map.delete(:user)

    {:ok, pid} =
      Querystream.start_query(
        fn query -> Request.fetch(:get, path(), query: query, user: user) end,
        "speeches",
        query
      )

    pid
  end

  defp page_response(response) do
    content = JSON.decode!(response)
    {content["cursor"], Enum.map(content["speeches"], &build/1)}
  end

  defp build(json) do
    API.from_api_json(json, &resource_maker/1)
  end
end
