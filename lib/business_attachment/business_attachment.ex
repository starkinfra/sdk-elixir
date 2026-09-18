defmodule StarkInfra.BusinessAttachment do
  alias __MODULE__, as: BusinessAttachment
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups BusinessAttachment related functions
  """

  @doc """
  A BusinessAttachment represents a document (articles of incorporation, bylaws, etc.) sent
  to a BusinessIdentity. You must reference the desired BusinessIdentity by its id.
  A BusinessIdentity accepts at most 2 attachments.
  When you initialize a BusinessAttachment, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the list of created structs.

  ## Parameters (required):
    - `:name` [string]: name of the document. Must be unique among the identity's "created" attachments. ex: "articles-of-incorporation.pdf"
    - `:content` [string]: Base64 data url of the document, or the raw file bytes when `:content_type` is given. ex: "data:application/pdf;base64,JVBERi0xLjQ..."
    - `:business_identity_id` [string]: unique id of the BusinessIdentity this attachment belongs to. ex: "5656565656565656"

  ## Parameters (optional):
    - `:content_type` [string, default nil]: content MIME type. Input only: when given, the SDK encodes `:content` into the base64 data url the API expects. ex: "application/pdf", "image/png" or "image/jpeg"
    - `:tags` [list of strings, default []]: list of strings for reference when searching for BusinessAttachments. ex: ["doc-principal"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the BusinessAttachment is created. ex: "5656565656565656"
    - `:attachment_id` [string]: id of the document in the external ms-attachment. ex: "5104320788332544"
    - `:status` [string]: current status of the BusinessAttachment. ex: "created", "canceled", "approved", "denied"
    - `:created` [DateTime]: creation datetime for the BusinessAttachment. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the BusinessAttachment. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :name,
    :content,
    :business_identity_id
  ]
  defstruct [
    :name,
    :content,
    :business_identity_id,
    :content_type,
    :tags,
    :id,
    :attachment_id,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Create BusinessAttachments in the Stark Infra API

  ## Parameters (required):
    - `:attachments` [list of BusinessAttachment]: list of BusinessAttachment structs to be created in the API. Limited to 1 attachment per request. Only PDF, JPG and PNG files up to 8 MB are accepted; name must be unique among the identity's other "created" attachments; and the target BusinessIdentity must be in "created"/"pending" status with fewer than 2 attachments already on it.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of BusinessAttachment structs with updated attributes
  """
  @spec create(
    attachments: [BusinessAttachment.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [BusinessAttachment.t()]} |
    {:error, Error.t()}
  def create(attachments, options \\ []) do
    Rest.post(
      resource(),
      Enum.map(attachments, &encode_content/1),
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    attachments: [BusinessAttachment.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(attachments, options \\ []) do
    Rest.post!(
      resource(),
      Enum.map(attachments, &encode_content/1),
      options
    )
  end

  @doc """
  Retrieve the BusinessAttachment struct linked to your Workspace in the Stark Infra API using its id.

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656".

  ## Options:
    - `:expand` [list of strings, default nil]: fields to expand information. ex: ["content"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - BusinessAttachment struct that corresponds to the given id.
  """
  @spec get(
    id: binary,
    expand: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, BusinessAttachment.t()} |
    {:error, Error.t()}
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
  Receive a stream of BusinessAttachment structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "canceled", "approved", "denied"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["doc-principal"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of BusinessAttachment structs with updated attributes
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
    {:ok, [BusinessAttachment.t()]} |
    {:error, Error.t()}
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
  Receive a list of up to 100 BusinessAttachment structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "canceled", "approved", "denied"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["doc-principal"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of BusinessAttachment structs with updated attributes
    - cursor to retrieve the next page of BusinessAttachment structs
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
    {:ok, {binary, [BusinessAttachment.t()]}} |
    {:error, Error.t()}
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
  Cancel a BusinessAttachment entity previously created in the Stark Infra API. Only attachments
  in the 'created' status can be canceled.

  ## Parameters (required):
    - `:id` [string]: BusinessAttachment unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled BusinessAttachment struct
  """
  @spec cancel(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, BusinessAttachment.t()} |
    {:error, Error.t()}
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
      "BusinessAttachment",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %BusinessAttachment{
      name: json[:name],
      content: json[:content],
      business_identity_id: json[:business_identity_id],
      tags: json[:tags],
      id: json[:id],
      attachment_id: json[:attachment_id],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime(),
    }
  end

  # content_type only exists to build the base64 data url the API expects; it is
  # never a wire field, so it is dropped once content carries the encoded value.
  defp encode_content(%BusinessAttachment{content: content, content_type: content_type} = attachment)
    when is_binary(content) and is_binary(content_type) do
    %{attachment | content: "data:#{content_type};base64,#{Base.encode64(content)}", content_type: nil}
  end

  defp encode_content(%{content: content, content_type: content_type} = attachment)
    when is_binary(content) and is_binary(content_type) do
    attachment
    |> Map.put(:content, "data:#{content_type};base64,#{Base.encode64(content)}")
    |> Map.delete(:content_type)
  end

  defp encode_content(attachment) do
    attachment
  end
end
