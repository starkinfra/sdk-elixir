defmodule StarkInfra.Ledger do
  alias __MODULE__, as: Ledger
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.API
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error
  alias StarkInfra.Ledger.Rule

  @moduledoc """
  Groups Ledger related functions
  """

  @doc """
  Ledgers are used to track the balance of a given amount by inserting
  LedgerTransactions to them. They can represent a bank account, a digital
  wallet, an inventory product, etc.
  When you initialize a Ledger, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:external_id` [string]: string that must be unique among all your Ledgers. ex: "my-internal-id-123456"

  ## Parameters (optional):
    - `:rules` [list of Rule structs or maps, default nil]: list of Rule structs linked to the Ledger. Rules are used to limit the balance of the Ledger. ex: [%StarkInfra.Ledger.Rule{key: "minimumBalance", value: 0}]
    - `:tags` [list of strings, default nil]: list of strings for reference when searching for Ledgers. ex: ["account/123", "savings"]
    - `:metadata` [map, default nil]: map used to store additional information about the Ledger struct. ex: %{"accountId" => "123", "accountType" => "savings"}

  ## Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when the Ledger is created. ex: "5656565656565656"
    - `:created` [DateTime, default nil]: creation datetime for the Ledger. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime, default nil]: latest update datetime for the Ledger. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :external_id
  ]
  defstruct [
    :external_id,
    :rules,
    :tags,
    :metadata,
    :id,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of Ledger structs for creation at the Stark Infra API

  ## Parameters (required):
    - `:ledgers` [list of Ledger structs]: list of Ledger structs to be created in the API. You can send up to 100 Ledger structs in a single request.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of Ledger structs with updated attributes
  """
  @spec create(
    [Ledger.t() | map],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [Ledger.t()]} |
    {:error, [Error.t()]}
  def create(ledgers, options \\ []) do
    Rest.post(
      resource(),
      ledgers,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    [Ledger.t() | map],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(ledgers, options \\ []) do
    Rest.post!(
      resource(),
      ledgers,
      options
    )
  end

  @doc """
  Receive a single Ledger struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Ledger struct with updated attributes
  """
  @spec get(
    binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, Ledger.t()} |
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
    binary,
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
  Receive a stream of Ledger structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:ids` [list of strings, default nil]: list of Ledger ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:external_ids` [list of strings, default nil]: list of Ledger external ids to filter retrieved structs. ex: ["my-internal-id-123456", "my-internal-id-654321"]
    - `:tags` [list of strings, default nil]: list of tags to filter retrieved structs. ex: ["account/123", "savings"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of Ledger structs with updated attributes
  """
  @spec query(
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    ids: [binary] | nil,
    external_ids: [binary] | nil,
    tags: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    ({:cont, {:ok, [Ledger.t() | map]}} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any ->  any)
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
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    ids: [binary] | nil,
    external_ids: [binary] | nil,
    tags: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 Ledger structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:ids` [list of strings, default nil]: list of Ledger ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:external_ids` [list of strings, default nil]: list of Ledger external ids to filter retrieved structs. ex: ["my-internal-id-123456", "my-internal-id-654321"]
    - `:tags` [list of strings, default nil]: list of tags to filter retrieved structs. ex: ["account/123", "savings"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of Ledger structs with updated attributes and cursor to retrieve the next page of Ledger structs
  """
  @spec page(
    cursor: binary | nil,
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    ids: [binary] | nil,
    external_ids: [binary] | nil,
    tags: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [Ledger.t()]}} |
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
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    ids: [binary] | nil,
    external_ids: [binary] | nil,
    tags: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Update a Ledger by passing its id.

  ## Parameters (required):
    - `:id` [string]: Ledger id. ex: "5656565656565656"

  ## Options:
    - `:rules` [list of Rule structs or maps, default nil]: list of Rule structs linked to the Ledger. Rules are used to limit the balance of the Ledger. ex: [%StarkInfra.Ledger.Rule{key: "minimumBalance", value: 0}]
    - `:tags` [list of strings, default nil]: list of strings for reference when searching for Ledgers. ex: ["account/123", "savings"]
    - `:metadata` [map, default nil]: map used to store additional information about the Ledger struct. ex: %{"accountId" => "123", "accountType" => "savings"}
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target Ledger struct with updated attributes
  """
  @spec update(
    binary,
    rules: [Rule.t() | map] | nil,
    tags: [binary] | nil,
    metadata: map | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, Ledger.t()} |
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
    binary,
    rules: [Rule.t() | map] | nil,
    tags: [binary] | nil,
    metadata: map | nil,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def update!(id, options \\ []) do
    Rest.patch_id!(
      resource(),
      id,
      options
    )
  end

  @doc false
  def resource() do
    {
      "Ledger",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Ledger{
      external_id: json[:external_id],
      rules: json[:rules] && Enum.map(json[:rules], fn rule -> API.from_api_json(rule, &Rule.resource_maker/1) end),
      tags: json[:tags],
      metadata: json[:metadata],
      id: json[:id],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
