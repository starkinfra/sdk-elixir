defmodule StarkInfra.IndividualAccountAttachment do
  alias __MODULE__, as: IndividualAccountAttachment
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IndividualAccountAttachment related functions
  """

  @doc """
  You can create an IndividualAccountAttachment to attach images of documents
  to a specific IndividualAccountRequest. You must reference the desired
  IndividualAccountRequest by its id.
  When you initialize an IndividualAccountAttachment, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:type` [string]: type of the IndividualAccountAttachment. Options: "identity-front", "identity-back", "drivers-license-front", "drivers-license-back"
    - `:content` [binary]: raw image bytes of the picture. ex: File.read!("file.png")
    - `:content_type` [string]: content MIME type, consumed to build the base64 data url sent to the API. ex: "image/png" or "image/jpeg"
    - `:account_request_id` [string]: unique id of the IndividualAccountRequest. ex: "5656565656565656"

  ## Parameters (optional):
    - `:tags` [list of strings, default nil]: list of strings for reference when searching for IndividualAccountAttachments. ex: ["employees", "monthly"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the IndividualAccountAttachment is created. ex: "5656565656565656"
    - `:status` [string]: current status of the IndividualAccountAttachment. Options: "created", "canceled", "processing", "success", "failed", "deleted"
    - `:created` [DateTime]: creation datetime for the IndividualAccountAttachment. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :type,
    :content,
    :content_type,
    :account_request_id
  ]
  defstruct [
    :type,
    :content,
    :content_type,
    :account_request_id,
    :tags,
    :id,
    :status,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of IndividualAccountAttachment structs for creation at the Stark Infra API

  ## Parameters (required):
    - `:attachments` [list of IndividualAccountAttachment structs]: list of IndividualAccountAttachment structs to be created in the API. The API accepts a single attachment per create call.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IndividualAccountAttachment structs with updated attributes
  """
  @spec create(
    attachments: [IndividualAccountAttachment.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [IndividualAccountAttachment.t()]} |
    {:error, [Error.t()]}
  def create(attachments, options \\ []) do
    Rest.post(
      resource(),
      attachments |> Enum.map(&encode_content/1),
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    attachments: [IndividualAccountAttachment.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(attachments, options \\ []) do
    Rest.post!(
      resource(),
      attachments |> Enum.map(&encode_content/1),
      options
    )
  end

  @doc """
  Receive a single IndividualAccountAttachment struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IndividualAccountAttachment struct with updated attributes
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IndividualAccountAttachment.t()} |
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
    user: Organization.t() | Project.t() | nil
  ) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(
      resource(),
      id,
      options
    )
  end

  @doc """
  Receive a stream of IndividualAccountAttachment structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: "created", "canceled", "processing", "success", "failed", "deleted"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["employees", "monthly"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IndividualAccountAttachment structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [IndividualAccountAttachment.t()]} |
    {:error, [Error.t()]}
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
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 IndividualAccountAttachment structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: "created", "canceled", "processing", "success", "failed", "deleted"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["employees", "monthly"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IndividualAccountAttachment structs with updated attributes
    - cursor to retrieve the next page of IndividualAccountAttachment structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IndividualAccountAttachment.t()]}} |
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
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Cancel an IndividualAccountAttachment entity previously created in the Stark Infra API.
  Only attachments whose parent IndividualAccountRequest is still in "created" status can be canceled.

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled IndividualAccountAttachment struct
  """
  @spec cancel(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IndividualAccountAttachment.t()} |
    {:error, [Error.t()]}
  def cancel(id, options \\ []) do
    Rest.delete_id(
      resource(),
      id,
      options
    )
  end

  @doc """
  Same as cancel(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec cancel!(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def cancel!(id, options \\ []) do
    Rest.delete_id!(
      resource(),
      id,
      options
    )
  end

  @doc false
  def resource() do
    {
      "IndividualAccountAttachment",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IndividualAccountAttachment{
      type: json[:type],
      content: json[:content],
      content_type: json[:content_type],
      account_request_id: json[:account_request_id],
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      created: json[:created] |> Check.datetime()
    }
  end

  # content_type only exists to build the base64 data url the API expects; it is
  # never a wire field, so it is dropped once content carries the encoded value.
  defp encode_content(%IndividualAccountAttachment{content: content, content_type: content_type} = attachment)
    when is_binary(content) and is_binary(content_type) do
    %{attachment | content: "data:#{content_type};base64,#{Base.encode64(content)}", content_type: nil}
  end

  defp encode_content(attachment) do
    attachment
  end
end
