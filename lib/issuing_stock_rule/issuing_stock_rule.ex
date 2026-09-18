defmodule StarkInfra.IssuingStockRule do
  alias __MODULE__, as: IssuingStockRule
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IssuingStockRule related functions
  """

  @doc """
  The IssuingStockRule struct displays the notification rules of a specific IssuingStock.
  When the stock balance reaches the minimum_balance, the recipients informed in the rule are notified.
  When you initialize a IssuingStockRule, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:minimum_balance` [integer]: stock balance threshold that triggers a notification. ex: 10000
    - `:stock_id` [string]: IssuingStock unique id to which the rule is linked. ex: "5656565656565656"

  ## Parameters (optional):
    - `:tags` [list of strings, default nil]: list of strings for tagging. ex: ["card", "corporate"]
    - `:emails` [list of strings, default nil]: list of up to 10 emails to notify when the stock reaches minimum_balance. At least one of emails or phones is required. ex: ["john.doe@enterprise.com"]
    - `:phones` [list of strings, default nil]: list of up to 10 phone numbers to notify when the stock reaches minimum_balance. At least one of emails or phones is required. ex: ["+55 (11) 91234 5678"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when IssuingStockRule is created. ex: "5656565656565656"
    - `:status` [string]: current IssuingStockRule status. Options: "active", "canceled"
    - `:created` [DateTime]: creation datetime for the IssuingStockRule. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the IssuingStockRule. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :minimum_balance,
    :stock_id
  ]
  defstruct [
    :minimum_balance,
    :stock_id,
    :tags,
    :emails,
    :phones,
    :id,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of IssuingStockRule structs for creation at the Stark Infra API

  ## Parameters (required):
    - `:rules` [list of IssuingStockRule structs]: list of IssuingStockRule structs to be created in the API. You can send up to 100 IssuingStockRule structs in a single request.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingStockRule structs with updated attributes
  """
  @spec create(
    rules: [IssuingStockRule.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [IssuingStockRule.t()]} |
    {:error, [Error.t()]}
  def create(rules, options \\ []) do
    Rest.post(
      resource(),
      rules,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    rules: [IssuingStockRule.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(rules, options \\ []) do
    Rest.post!(
      resource(),
      rules,
      options
    )
  end

  @doc """
  Receive a stream of IssuingStockRule structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: ["active", "canceled"]
    - `:stock_ids` [list of strings, default nil]: list of stock_ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["card", "corporate"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingStockRule structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    stock_ids: [binary],
    ids: [binary],
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    ({:cont, {:ok, [IssuingStockRule.t()]}} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
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
    stock_ids: [binary],
    ids: [binary],
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    ({:cont, [IssuingStockRule.t()]} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 IssuingStockRule structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: ["active", "canceled"]
    - `:stock_ids` [list of strings, default nil]: list of stock_ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["card", "corporate"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingStockRule structs with updated attributes
    - cursor to retrieve the next page of IssuingStockRule structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    stock_ids: [binary],
    ids: [binary],
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IssuingStockRule.t()]}} |
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
    stock_ids: [binary],
    ids: [binary],
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
  Update an IssuingStockRule by passing id.

  ## Parameters (required):
    - `:id` [string]: IssuingStockRule id. ex: '5656565656565656'

  ## Parameters (optional):
    - `:minimum_balance` [integer, default nil]: stock balance threshold that triggers a notification. ex: 10000
    - `:tags` [list of strings, default nil]: list of strings for tagging. ex: ["card", "corporate"]
    - `:emails` [list of strings, default nil]: list of emails to be notified when the stock reaches the minimum balance. ex: ["john.doe@enterprise.com"]
    - `:phones` [list of strings, default nil]: list of phones to be notified when the stock reaches the minimum balance. ex: ["+55 (11) 91234 5678"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target IssuingStockRule with updated attributes
  """
  @spec update(
    id: binary,
    minimum_balance: integer | nil,
    tags: [binary] | nil,
    emails: [binary] | nil,
    phones: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IssuingStockRule.t()} |
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
    minimum_balance: integer | nil,
    tags: [binary] | nil,
    emails: [binary] | nil,
    phones: [binary] | nil,
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
  Cancel an IssuingStockRule entity previously created in the Stark Infra API

  ## Parameters (required):
    - `:id` [string]: IssuingStockRule unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled IssuingStockRule struct
  """
  @spec cancel(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IssuingStockRule.t()} |
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
      "IssuingStockRule",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingStockRule{
      minimum_balance: json[:minimum_balance],
      stock_id: json[:stock_id],
      tags: json[:tags],
      emails: json[:emails],
      phones: json[:phones],
      id: json[:id],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
