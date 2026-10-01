defmodule StarkInfra.AiTranscript do
  alias __MODULE__, as: AiTranscript
  alias StarkInfra.Utils.AiApi
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.Request
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups AiTranscript related functions
  """

  @doc """
  An AiTranscript is the text of an audio file you upload, from any speaker, cloned or not.
  When you initialize an AiTranscript, the struct will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:audio` [binary]: base64-encoded audio to transcribe. Up to 10000000 characters. The format is read from the file's own header.

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the AiTranscript is created. ex: "5656565656565656"
    - `:text` [binary]: transcribed text.
    - `:status` [binary]: current status of the transcript. Options: "processing", "success", "failed"
    - `:errors` [list of binaries]: reasons the transcription failed. Empty when it worked.
    - `:created` [DateTime]: creation datetime for the AiTranscript. ex: ~U[2020-03-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the AiTranscript. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :audio
  ]
  defstruct [
    :audio,
    :id,
    :text,
    :status,
    :errors,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send an AiTranscript struct for creation at the Stark Infra API. The audio is transcribed during the call.

  ## Parameters (required):
    - `:transcript` [AiTranscript struct]: AiTranscript struct to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - AiTranscript struct with updated attributes
  """
  @spec create(
    transcript: AiTranscript.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiTranscript.t()} |
    {:error, [Error.t()]}
  def create(transcript, options \\ []) do
    Request.fetch(
      :post,
      path(),
      # the API answers 400 to id, text, status and the other return-only fields, which a struct returned by query/create carries
      payload: AiApi.payload(transcript, [:audio]),
      user: options[:user]
    )
    |> AiApi.single("transcript", &resource_maker/1)
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    transcript: AiTranscript.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(transcript, options \\ []) do
    create(transcript, options) |> AiApi.unwrap!()
  end

  @doc """
  Receive a stream of AiTranscript structs previously created in the Stark Infra API.
  This route is not paginated and takes no filters, so there are no limit, cursor or filter options here.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of AiTranscript structs with updated attributes
  """
  @spec query(
    user: Project.t() | Organization.t() | nil
  ) :: Enumerable.t()
  def query(options \\ []) do
    AiApi.stream(fn -> list_result(options) end)
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
    user: Project.t() | Organization.t() | nil
  ) :: any
  def query!(options \\ []) do
    AiApi.stream!(fn -> list_result(options) end)
  end

  @doc false
  def resource() do
    {
      "AiTranscript",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %AiTranscript{
      audio: json[:audio],
      id: json[:id],
      text: json[:text],
      status: json[:status],
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
    Request.fetch(:get, path(), user: options[:user])
    |> AiApi.many("transcripts", &resource_maker/1)
  end
end
