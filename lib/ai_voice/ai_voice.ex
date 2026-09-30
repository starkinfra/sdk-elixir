defmodule StarkInfra.AiVoice do
  alias __MODULE__, as: AiVoice
  alias StarkInfra.Utils.AiApi
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.Request
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups AiVoice related functions
  """

  @doc """
  An AiVoice is a voice cloned from a recording you upload. Once cloned, it can read any text out loud through
  an AiSpeech, and it can be attached to an AiAgent so every reply carries a speech ready to be synthesized.
  Cloning is asynchronous: the voice is created in "processing" status and moves to "success" when it is ready
  to speak, or to "failed" when the recording could not be cloned.
  When you initialize an AiVoice, the struct will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:audio` [binary]: base64-encoded recording of the speaker. MP3, WAV, OGG, FLAC and WebM are accepted. Up to 10000000 characters.

  ## Parameters (optional):
    - `:name` [binary, default nil]: name of the voice. Up to 100 characters. Defaults to the voice's own id. ex: "Helena"
    - `:description` [binary, default nil]: free-text description of the voice. Up to 1000 characters. ex: "Calm voice"
    - `:language` [binary, default nil]: language the voice speaks. Options: "portuguese", "english". The API defaults to "portuguese".
    - `:gender` [binary, default nil]: gender of the voice. Options: "male", "female", "neutral"

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the AiVoice is created. This is the voice_id you send to other AI resources. ex: "5656565656565656"
    - `:status` [binary]: current status of the voice. Options: "processing", "success", "failed". Only a voice in "success" can speak.
    - `:errors` [list of binaries]: reasons the cloning failed. Empty while the voice is healthy.
    - `:created` [DateTime]: creation datetime for the AiVoice. ex: ~U[2020-03-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the AiVoice. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :audio
  ]
  defstruct [
    :audio,
    :name,
    :description,
    :language,
    :gender,
    :id,
    :status,
    :errors,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send an AiVoice struct for creation at the Stark Infra API and start cloning it.
  The call returns immediately with the voice in "processing" status.

  ## Parameters (required):
    - `:voice` [AiVoice struct]: AiVoice struct to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - AiVoice struct with updated attributes
  """
  @spec create(
    voice: AiVoice.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiVoice.t()} |
    {:error, [Error.t()]}
  def create(voice, options \\ []) do
    Request.fetch(
      :post,
      path(),
      # the API answers 400 to id, status, errors, created and updated, which a struct returned by query/create carries
      payload: AiApi.payload(voice, [:audio, :name, :description, :language, :gender]),
      user: options[:user]
    )
    |> AiApi.single("voice", &resource_maker/1)
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    voice: AiVoice.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(voice, options \\ []) do
    create(voice, options) |> AiApi.unwrap!()
  end

  @doc """
  Receive a stream of AiVoice structs previously created in the Stark Infra API.
  This route is not paginated and takes no filters, so there are no limit, cursor or filter options here.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of AiVoice structs with updated attributes
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

  @doc """
  Delete up to 100 AiVoices at once.

  ## Parameters (required):
    - `:ids` [list of binaries]: ids of the AiVoices to be deleted. Up to 100 ids. ex: ["5656565656565656", "4545454545454545"]

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of deleted AiVoice structs
  """
  @spec delete(
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [AiVoice.t()]} |
    {:error, [Error.t()]}
  def delete(ids, options \\ []) do
    # ids travel in the query string: this route takes no body
    Request.fetch(
      :delete,
      path(),
      query: %{ids: ids},
      user: options[:user]
    )
    |> AiApi.many("voices", &resource_maker/1)
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
      "AiVoice",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %AiVoice{
      audio: json[:audio],
      name: json[:name],
      description: json[:description],
      language: json[:language],
      gender: json[:gender],
      id: json[:id],
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
    |> AiApi.many("voices", &resource_maker/1)
  end
end
