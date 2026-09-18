defmodule StarkInfra.IndividualIdentity do
  alias __MODULE__, as: IndividualIdentity
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IndividualIdentity related functions
  """

  @doc """
  An IndividualIdentity runs an end-to-end identity verification on a Brazilian individual.
  It wraps the proofs (document and/or facial biometrics) the holder must submit; Stark Infra
  orchestrates the collection, validates each proof and delivers the result through the
  'individual-identity' webhook subscription.
  When you initialize an IndividualIdentity, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:name` [string]: full name of the holder being verified. ex: "Walter White"
    - `:email` [string]: e-mail used to deliver the validator_link when delivery_method is "automatic". ex: "walter.white@email.com"
    - `:delivery_method` [string]: how the validator_link reaches the holder. Options: "automatic", "manual"
    - `:proofs` [list of strings]: list of proof types to collect. Options: "identity", "biometric"

  ## Parameters (optional):
    - `:tax_id` [string, default nil]: individual's tax ID (CPF), with or without punctuation. ex: "012.345.678-90"
    - `:phone` [string, default nil]: holder's phone in international format. ex: "+5511987654321"
    - `:tags` [list of strings, default nil]: list of strings for reference when searching for IndividualIdentities. ex: ["employees", "monthly"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the IndividualIdentity is created. ex: "5656565656565656"
    - `:proofs` [list of strings]: list of proof types required by the identity. Options: "identity", "biometric"
    - `:validator_link` [string]: URL the holder opens to submit each proof.
    - `:source_id` [string]: id of the entity that triggered this verification.
    - `:source_type` [string]: origin of the verification. Options: "onboarding", "reboarding", "external"
    - `:workspace_id` [string]: id of the workspace that owns this identity.
    - `:status` [string]: current status of the IndividualIdentity. Options: "created", "processing", "pending", "success", "failed"
    - `:created` [DateTime]: creation datetime for the IndividualIdentity. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the IndividualIdentity. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :name,
    :email,
    :delivery_method,
    :proofs
  ]
  defstruct [
    :name,
    :email,
    :delivery_method,
    :proofs,
    :tax_id,
    :phone,
    :tags,
    :id,
    :validator_link,
    :source_id,
    :source_type,
    :workspace_id,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of IndividualIdentity structs for creation at the Stark Infra API

  ## Parameters (required):
    - `:identities` [list of IndividualIdentity structs]: list of IndividualIdentity structs to be created in the API. You can send up to 100 IndividualIdentity structs in a single request.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IndividualIdentity structs with updated attributes
  """
  @spec create(
    identities: [IndividualIdentity.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [IndividualIdentity.t()]} |
    {:error, [Error.t()]}
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
    identities: [IndividualIdentity.t() | map()],
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
  Receive a single IndividualIdentity struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IndividualIdentity struct with updated attributes
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IndividualIdentity.t()} |
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
  Receive a stream of IndividualIdentity structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: "created", "processing", "pending", "success", "failed"
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tax_ids` [list of strings, default nil]: list of CPFs to filter retrieved structs. ex: ["012.345.678-90"]
    - `:email` [string, default nil]: filter for the holder's e-mail.
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["employees", "monthly"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IndividualIdentity structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    ids: [binary],
    tax_ids: [binary],
    email: binary,
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [IndividualIdentity.t()]} |
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
    ids: [binary],
    tax_ids: [binary],
    email: binary,
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 IndividualIdentity structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: "created", "processing", "pending", "success", "failed"
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tax_ids` [list of strings, default nil]: list of CPFs to filter retrieved structs. ex: ["012.345.678-90"]
    - `:email` [string, default nil]: filter for the holder's e-mail.
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["employees", "monthly"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IndividualIdentity structs with updated attributes
    - cursor to retrieve the next page of IndividualIdentity structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    ids: [binary],
    tax_ids: [binary],
    email: binary,
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IndividualIdentity.t()]}} |
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
    ids: [binary],
    tax_ids: [binary],
    email: binary,
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Update the tax_id of an IndividualIdentity after it has been created.
  Useful when the CPF is unknown at creation time and is only collected during the proof submission flow.

  ## Parameters (required):
    - `:id` [string]: IndividualIdentity id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:tax_id` [string, default nil]: CPF to assign to the identity, with or without punctuation. ex: "012.345.678-90"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target IndividualIdentity with updated attributes
  """
  @spec update(
    id: binary,
    tax_id: binary | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IndividualIdentity.t()} |
    {:error, [Error.t()]}
  def update(id, options \\ []) do
    Rest.patch_id(
      resource(),
      id,
      options
    )
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(
    id: binary,
    tax_id: binary | nil,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def update!(id, options \\ []) do
    Rest.patch_id!(
      resource(),
      id,
      options
    )
  end

  @doc """
  Cancel an IndividualIdentity entity previously created in the Stark Infra API.
  The identity transitions to "failed", every pending proof is canceled and a "canceled"
  log is delivered through the webhook. Only identities in "created" or "pending" status can be canceled.

  ## Parameters (required):
    - `:id` [string]: IndividualIdentity unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled IndividualIdentity struct
  """
  @spec cancel(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IndividualIdentity.t()} |
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
      "IndividualIdentity",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IndividualIdentity{
      name: json[:name],
      email: json[:email],
      delivery_method: json[:delivery_method],
      proofs: json[:proofs],
      tax_id: json[:tax_id],
      phone: json[:phone],
      tags: json[:tags],
      id: json[:id],
      validator_link: json[:validator_link],
      source_id: json[:source_id],
      source_type: json[:source_type],
      workspace_id: json[:workspace_id],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
