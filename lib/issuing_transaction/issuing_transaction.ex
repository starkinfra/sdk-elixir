defmodule StarkInfra.IssuingTransaction do
  alias __MODULE__, as: IssuingTransaction
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
    # IssuingTransaction struct
  """

  @doc """
  The IssuingTransaction structs created in your Workspace to represent each balance shift.

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when IssuingTransaction is created. ex: "5656565656565656"
    - `:amount` [integer]: IssuingTransaction value in cents. ex: 1234 (= R$ 12.34)
    - `:balance` [integer]: balance amount of the Workspace at the instant of the Transaction in cents. ex: 200 (= R$ 2.00)
    - `:description` [string]: IssuingTransaction description. ex: "Buying food"
    - `:source` [string]: source of the transaction. ex: "issuing-purchase/5656565656565656"
    - `:tags` [string]: list of strings inherited from the source resource. ex: ["tony", "stark"]
    - `:created` [DateTime]: creation datetime for the IssuingTransaction. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :amount,
    :description,
    :balance,
    :source,
    :tags,
    :id,
    :created
  ]
  defstruct [
    :amount,
    :description,
    :balance,
    :source,
    :tags,
    :id,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single IssuingTransaction struct previously created in the Stark Infra API by its id

  ## Options:
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingTransaction struct with updated attributes
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IssuingTransaction.t()} |
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
  Receive a stream of IssuingTransaction structs previously created in the Stark Infra API

  ## Options:
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:external_ids` [list of strings, default []]: external IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "approved", "canceled", "denied", "confirmed" or "voided"
    - `:ids` [list of strings, default [], default nil]: purchase IDs
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingTransaction structs with updated attributes
  """
  @spec query(
    tags: [binary] | nil,
    external_ids: [binary] | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: binary | nil,
    ids: [binary] | nil,
    limit: integer | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IssuingTransaction.t()]}} |
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
    tags: [binary] | nil,
    external_ids: [binary] | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: binary | nil,
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
  Receive a list of IssuingTransaction structs previously created in the Stark Infra API and the cursor to the next page.

  ## Options:
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:external_ids` [list of strings, default []]: external IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "approved", "canceled", "denied", "confirmed" or "voided"
    - `:ids` [list of strings, default [], default nil]: purchase IDs
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingTransaction structs with updated attributes
    - cursor to retrieve the next page of IssuingPurchase structs
  """
  @spec page(
    tags: [binary] | nil,
    external_ids: [binary] | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: binary | nil,
    ids: [binary] | nil,
    limit: integer | nil,
    cursor: binary | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IssuingTransaction.t()]}} |
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
    tags: [binary] | nil,
    external_ids: [binary] | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: binary | nil,
    ids: [binary] | nil,
    limit: integer | nil,
    cursor: binary | nil,
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
      "IssuingTransaction",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingTransaction{
      id: json[:id],
      tags: json[:tags],
      amount: json[:amount],
      source: json[:source],
      balance: json[:balance],
      description: json[:description],
      created: json[:created] |> Check.datetime()
    }
  end
end
