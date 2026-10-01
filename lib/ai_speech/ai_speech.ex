defmodule StarkInfra.AiSpeech do
  alias __MODULE__, as: AiSpeech
  alias StarkInfra.Utils.AiApi
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.Request
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
    - `:audio` [binary]: base64-encoded MP3 of the speech. Left out of query results; get returns it unless fields is given without it.
    - `:voice_name` [binary]: name of the voice. Only present when requested with expand: [:voice_name].
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
    Request.fetch(
      :post,
      path(),
      # the API answers 400 to id, status, audio and the other return-only fields, which a struct returned by get/create carries
      payload: AiApi.payload(speech, [:voice_id, :text]),
      user: options[:user]
    )
    |> AiApi.single("speech", &resource_maker/1)
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    speech: AiSpeech.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(speech, options \\ []) do
    create(speech, options) |> AiApi.unwrap!()
  end

  @doc """
  Receive a single AiSpeech struct previously created in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [binary]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:fields` [list of atoms, default nil]: attributes to keep in the response. The audio is only attached when fields is omitted or lists :audio. ex: [:id, :status, :audio]
    - `:expand` [list of atoms, default nil]: extra attributes to compute. Options: [:voice_name]. When fields is also given, the expanded attribute must be listed there too.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - AiSpeech struct with updated attributes
  """
  @spec get(
    id: binary,
    fields: [atom] | nil,
    expand: [atom] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiSpeech.t()} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Request.fetch(
      :get,
      "#{path()}/#{id}",
      query: AiApi.fields_and_expand(options),
      user: options[:user]
    )
    |> AiApi.single("speech", &resource_maker/1)
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
  Receive a stream of AiSpeech structs previously created in the Stark Infra API. The audio is left out of the results.
  This route is not paginated and rejects limit, cursor and every filter, so they are not options here.

  ## Options:
    - `:fields` [list of atoms, default nil]: attributes to keep in the response. ex: [:id, :status]
    - `:expand` [list of atoms, default nil]: extra attributes to compute. Options: [:voice_name]. When fields is also given, the expanded attribute must be listed there too.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of AiSpeech structs with updated attributes
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

  defp list_result(options) do
    # the list key is "speeches", which the core would derive as "speechs"
    Request.fetch(
      :get,
      path(),
      query: AiApi.fields_and_expand(options),
      user: options[:user]
    )
    |> AiApi.many("speeches", &resource_maker/1)
  end
end
