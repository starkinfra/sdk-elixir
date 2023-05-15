defmodule StarkInfra.IndividualDocument do
  alias __MODULE__, as: IndividualDocument
  alias StarkInfra.Error
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization

  @moduledoc """
  Groups IndividualDocument related functions
  """

  @doc """
  Individual documents are images containing either side of a document or a selfie
  to be used in a matching validation. When created, they must be attached to an individual
  identity to be used for its validation.

  When you initialize a IndividualDocument, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the objects
  to the Stark Infra API and returns the list of created objects.

  ## Parameters (required):
    - `:type` [binary]: type of the IndividualDocument. Options: "drivers-license-front", "drivers-license-back", "identity-front", "identity-back" or "selfie"
    - `:content` [binary]: Base64 data url of the picture. ex: data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAASABIAAD...
    - `:content_type` [binary]: content MIME type. This parameter is required as input only. ex: "image/png" or "image/jpeg"
    - `:identity_id` [integer]: Unique id of IndividualIdentity. ex: "5656565656565656"

  ## Parameters (optional):
    - `:tags` [list of binaries, default []]: list of binaries for reference when searching for IndividualDocuments. ex: [\"employees\", \"monthly\"]

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the IndividualDocument is created. ex: "5656565656565656"
    - `:status` [binary]: current status of the IndividualDocument. Options: "created", "canceled", "processing", "failed", "success"
    - `:created` [DateTime]: creation DateTime for the IndividualDocument. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :type,
    :content,
    :content_type,
    :identity_id
  ]
  defstruct [
    :type,
    :content,
    :content_type,
    :identity_id,
    :tags,
    :id,
    :status,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of IndividualDocument objects for creation in the Stark Infra API

  ## Parameters (required):
    - `:documents` [list of IndividualDocument objects]: list of IndividualDocument objects to be created in the API

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IndividualDocument objects with updated attributes
  """
  @spec create(
    [IndividualDocument.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [IndividualDocument.t()]} |
    {:error, [Error.t()]}
  def create(documents, options \\ []) do
    Rest.post(
      resource(),
      set_content(documents),
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    [IndividualDocument.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(documents, options \\ []) do
    Rest.post!(
      resource(),
      set_content(documents),
      options
    )
  end

  @doc """
  Receive a single IndividualDocument object previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [binary]: object's unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IndividualDocument object that corresponds to the given id.
  """
  @spec get(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [IndividualDocument.t()]} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of IndividualDocument objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020, 3, 10]
    - `:status` [binary, default nil]: filter for status of retrieved objects. ex: “canceled”, “created”, “expired”, “failed”, “processing”, “signed”, “success”.
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IndividualDocument objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    tags: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, {:ok, [IndividualDocument.t()]}} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query(options \\ []) do
    Rest.get_list(resource(), options)
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    tags: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, [IndividualDocument.t()]} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 IndividualDocument objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: Date filter for objects created only after specified date. ex: ~D[2020-3-10]
    - `:before` [Date or binary, default nil]: Date filter for objects created only before specified date. ex: ~D(2020-3-10]
    - `:status` [binary, default nil]: filter for status of retrieved objects. ex: “canceled”, “created”, “expired”, “failed”, “processing”, “signed”, “success”.
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IndividualDocument objects with updated attributes
    - cursor to retrieve the next page of IndividualDocument objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    tags: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [IndividualDocument.t()]}} |
    {:error, [Error.t()]}
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    tags: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    [IndividualDocument.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "IndividualDocument",
      &resource_maker/1
    }
  end

  @doc false
  def set_content(data) do
    Enum.map(data, fn (document) ->
      case document.content_type do
        nil -> document
        _ -> %{
          :content => "data:" <> document.content_type <> ";base64," <> (document.content |> Base.encode64() |> to_string()),
          :type => document.type,
          :identity_id => document.identity_id,
          :tags => document.tags
        }
      end
    end)
  end

  @doc false
  def resource_maker(json) do
    %IndividualDocument{
      type: json[:type],
      content: json[:content],
      content_type: json[:content_type],
      identity_id: json[:identity_id],
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      created: json[:created],
    }
  end
end
