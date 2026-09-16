defmodule StarkInfra.LedgerTransaction do
  alias __MODULE__, as: LedgerTransaction
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.API
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error
  alias StarkInfra.Ledger.Rule

  @moduledoc """
  Groups LedgerTransaction related functions
  """

  @doc """
  LedgerTransactions are used to track the balance of a given amount by
  inserting LedgerTransactions to a Ledger. They can represent a bank
  account, a digital wallet, an inventory product, etc.
  When you initialize a LedgerTransaction, the entity will not be
  automatically created in the Stark Infra API. The 'create' function
  sends the structs to the Stark Infra API and returns the created
  structs.

  ## Parameters (required):
    - `:amount` [integer]: amount of the transaction. ex: 11234
    - `:ledger_id` [string]: id of the Ledger containing the transaction. ex: "5656565656565656"
    - `:external_id` [string]: string that must be unique among all your LedgerTransactions in a single Ledger. ex: "my-internal-id-123456"
    - `:source` [string]: source of the LedgerTransaction. ex: "bank-transfer/123"

  ## Parameters (optional):
    - `:fee` [integer, default nil]: fee applied to the LedgerTransaction. ex: 100
    - `:rules` [list of Rule structs or maps, default nil]: list of Rule structs linked to the LedgerTransaction. Rules are used to overwrite the Ledger's rules for this transaction. ex: [%StarkInfra.Ledger.Rule{key: "minimumBalance", value: 0}]
    - `:metadata` [map, default nil]: map used to store additional information about the LedgerTransaction struct. ex: %{"orderId" => "123", "orderType" => "purchase"}
    - `:tags` [list of strings, default nil]: list of strings for reference when searching for LedgerTransactions. ex: ["transfer/123", "savings"]
    - `:created` [DateTime or string, default nil]: datetime to backdate the transaction, used to import existing transaction history. Cannot be in the future; when creating multiple transactions in one request, their created values must be in chronological order. Defaults to the current datetime when omitted.

  ## Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when the LedgerTransaction is created. ex: "5656565656565656"
    - `:balance` [integer, default nil]: Ledger's balance after the transaction. ex: 11234
  """
  @enforce_keys [
    :amount,
    :ledger_id,
    :external_id,
    :source
  ]
  defstruct [
    :amount,
    :ledger_id,
    :external_id,
    :source,
    :fee,
    :rules,
    :metadata,
    :tags,
    :created,
    :id,
    :balance
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of LedgerTransaction structs for creation at the Stark Infra API

  ## Parameters (required):
    - `:transactions` [list of LedgerTransaction structs]: list of LedgerTransaction structs to be created in the API. You can send up to 500 structs in a single request, targeting different ledgers if needed; each is applied to its Ledger in the order sent, and the resulting balance is returned for each one.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of LedgerTransaction structs with updated attributes
  """
  @spec create(
    [LedgerTransaction.t() | map],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [LedgerTransaction.t()]} |
    {:error, [Error.t()]}
  def create(transactions, options \\ []) do
    Rest.post(
      resource(),
      transactions,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    [LedgerTransaction.t() | map],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(transactions, options \\ []) do
    Rest.post!(
      resource(),
      transactions,
      options
    )
  end

  @doc """
  Receive a single LedgerTransaction struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - LedgerTransaction struct with updated attributes
  """
  @spec get(
    binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, LedgerTransaction.t()} |
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
  Receive a stream of LedgerTransaction structs previously created in the Stark Infra API

  ## Parameters (conditionally required):
    - `:ledger_id` [string, default nil]: id of the Ledger containing the transaction. Either ledger_id or ids must be provided. If both are sent, the query will be filtered by both. ex: "5656565656565656"
    - `:ids` [list of strings, default nil]: list of LedgerTransaction ids to filter retrieved structs. Either ledger_id or ids must be provided. If both are sent, the query will be filtered by both. ex: ["5656565656565656", "4545454545454545"]

  ## Options:
    - `:flow` [string, default nil]: direction of the transaction. ex: "in" or "out"
    - `:tags` [list of strings, default nil]: list of tags to filter retrieved structs. ex: ["transfer/123", "savings"]
    - `:external_ids` [list of strings, default nil]: list of LedgerTransaction external ids to filter retrieved structs. ex: ["my-internal-id-123456", "my-internal-id-654321"]
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:limit` [integer, default 100, maximum 1000]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of LedgerTransaction structs with updated attributes
  """
  @spec query(
    ledger_id: binary | nil,
    flow: binary | nil,
    tags: [binary] | nil,
    external_ids: [binary] | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    ids: [binary] | nil,
    limit: integer | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    ({:cont, {:ok, [LedgerTransaction.t() | map]}} |
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
    ledger_id: binary | nil,
    flow: binary | nil,
    tags: [binary] | nil,
    external_ids: [binary] | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    ids: [binary] | nil,
    limit: integer | nil,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of LedgerTransaction structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (conditionally required):
    - `:ledger_id` [string, default nil]: id of the Ledger containing the transaction. Either ledger_id or ids must be provided. If both are sent, the query will be filtered by both. ex: "5656565656565656"
    - `:ids` [list of strings, default nil]: list of LedgerTransaction ids to filter retrieved structs. Either ledger_id or ids must be provided. If both are sent, the query will be filtered by both. ex: ["5656565656565656", "4545454545454545"]

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:flow` [string, default nil]: direction of the transaction. ex: "in" or "out"
    - `:tags` [list of strings, default nil]: list of tags to filter retrieved structs. ex: ["transfer/123", "savings"]
    - `:external_ids` [list of strings, default nil]: list of LedgerTransaction external ids to filter retrieved structs. ex: ["my-internal-id-123456", "my-internal-id-654321"]
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:limit` [integer, default 100, maximum 1000]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of LedgerTransaction structs with updated attributes and cursor to retrieve the next page of LedgerTransaction structs
  """
  @spec page(
    ledger_id: binary | nil,
    cursor: binary | nil,
    flow: binary | nil,
    tags: [binary] | nil,
    external_ids: [binary] | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    ids: [binary] | nil,
    limit: integer | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [LedgerTransaction.t()]}} |
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
    ledger_id: binary | nil,
    cursor: binary | nil,
    flow: binary | nil,
    tags: [binary] | nil,
    external_ids: [binary] | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    ids: [binary] | nil,
    limit: integer | nil,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc false
  def resource() do
    {
      "LedgerTransaction",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %LedgerTransaction{
      amount: json[:amount],
      ledger_id: json[:ledger_id],
      external_id: json[:external_id],
      source: json[:source],
      fee: json[:fee],
      rules: json[:rules] && Enum.map(json[:rules], fn rule -> API.from_api_json(rule, &Rule.resource_maker/1) end),
      metadata: json[:metadata],
      tags: json[:tags],
      created: json[:created] |> Check.datetime(),
      id: json[:id],
      balance: json[:balance]
    }
  end
end
