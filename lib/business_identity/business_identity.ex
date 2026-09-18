defmodule StarkInfra.BusinessIdentity do
  alias __MODULE__, as: BusinessIdentity
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups BusinessIdentity related functions
  """

  @doc """
  A BusinessIdentity represents the identity verification of a company (PJ), identified by
  its tax ID (CNPJ). It holds the company's registration data, the list of representatives,
  the attached documents, the extracted signature rules and the final verification status.
  When you initialize a BusinessIdentity, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the list of created structs.

  ## Parameters (required):
    - `:tax_id` [string]: company's tax ID (CNPJ). Must be a valid CNPJ, active in the official bureau, and returning at least one representative (sócio). ex: "20.018.183/0001-80"

  ## Parameters (optional):
    - `:tags` [list of strings, default []]: list of strings for reference when searching for BusinessIdentities. ex: ["onboarding-123"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the BusinessIdentity is created. ex: "5656565656565656"
    - `:name` [string]: company's legal name, filled from the bureau. ex: "STARK BANK S.A."
    - `:tax_id_status` [string]: status of the CNPJ at the bureau. ex: "active", "blocked", "pending"
    - `:insight_tax_id` [string]: tax ID extracted from the document by the insight. ex: "20.018.183/0001-80"
    - `:insight_document_type` [string]: document type detected by the insight. ex: "articles-of-incorporation"
    - `:representatives` [string]: JSON string of the company's representatives.
    - `:attachments` [list of strings]: list of attached documents references. ex: ["attachment/5656565656565656"]
    - `:num_pages` [integer]: number of pages of the document. ex: 5
    - `:rules` [string]: JSON string of the complemented signature rules.
    - `:status` [string]: current status of the BusinessIdentity. ex: "created", "pending", "processing", "canceled", "success", "failed"
    - `:created` [DateTime]: creation datetime for the BusinessIdentity. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the BusinessIdentity. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :tax_id
  ]
  defstruct [
    :tax_id,
    :tags,
    :id,
    :name,
    :tax_id_status,
    :insight_tax_id,
    :insight_document_type,
    :representatives,
    :attachments,
    :num_pages,
    :rules,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Create BusinessIdentities in the Stark Infra API

  ## Parameters (required):
    - `:identities` [list of BusinessIdentity]: list of BusinessIdentity structs to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of BusinessIdentity structs with updated attributes
  """
  @spec create(
    identities: [BusinessIdentity.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [BusinessIdentity.t()]} |
    {:error, Error.t()}
  def create(identities, options \\ []) do
    Rest.post(
      resource(),
      identities,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    identities: [BusinessIdentity.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(identities, options \\ []) do
    Rest.post!(
      resource(),
      identities,
      options
    )
  end

  @doc """
  Retrieve the BusinessIdentity struct linked to your Workspace in the Stark Infra API using its id.

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656".

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - BusinessIdentity struct that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, BusinessIdentity.t()} |
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
  Receive a stream of BusinessIdentity structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "pending", "processing", "canceled", "success", "failed"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["onboarding-123"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tax_ids` [list of strings, default nil]: list of company tax IDs (CNPJ) to filter retrieved structs. ex: ["20.018.183/0001-80"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of BusinessIdentity structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    tax_ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [BusinessIdentity.t()]} |
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
    tax_ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 BusinessIdentity structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "pending", "processing", "canceled", "success", "failed"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["onboarding-123"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tax_ids` [list of strings, default nil]: list of company tax IDs (CNPJ) to filter retrieved structs. ex: ["20.018.183/0001-80"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of BusinessIdentity structs with updated attributes
    - cursor to retrieve the next page of BusinessIdentity structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    tax_ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [BusinessIdentity.t()]}} |
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
    tax_ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Update a BusinessIdentity by passing id.

  ## Parameters (required):
    - `:id` [string]: BusinessIdentity id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:status` [string, default nil]: only "processing" is accepted, to trigger the AI Model analysis. The identity must currently be in "created"/"pending" status and must already have at least one BusinessAttachment associated with it.
    - `:tags` [list of strings, default nil]: list of strings for reference when searching for BusinessIdentities. ex: ["onboarding-123"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target BusinessIdentity with updated attributes
  """
  @spec update(
    id: binary,
    status: binary | nil,
    tags: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, BusinessIdentity.t()} |
    {:error, [Error.t()]}
  def update(id, parameters \\ []) do
    Rest.patch_id(
      resource(),
      id,
      parameters
    )
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(
    id: binary,
    status: binary | nil,
    tags: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def update!(id, parameters \\ []) do
    Rest.patch_id!(
      resource(),
      id,
      parameters
    )
  end

  @doc """
  Cancel a BusinessIdentity entity previously created in the Stark Infra API. Only identities
  in the 'created' or 'pending' status can be canceled.

  ## Parameters (required):
    - `:id` [string]: BusinessIdentity unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled BusinessIdentity struct
  """
  @spec cancel(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, BusinessIdentity.t()} |
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
      "BusinessIdentity",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %BusinessIdentity{
      tax_id: json[:tax_id],
      tags: json[:tags],
      id: json[:id],
      name: json[:name],
      tax_id_status: json[:tax_id_status],
      insight_tax_id: json[:insight_tax_id],
      insight_document_type: json[:insight_document_type],
      representatives: json[:representatives],
      attachments: json[:attachments],
      num_pages: json[:num_pages],
      rules: json[:rules],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime(),
    }
  end
end
