defmodule StarkInfra.IssuingWithdrawal do
  alias __MODULE__, as: IssuingWithdrawal
  alias StarkInfra.Error
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization

  @moduledoc """
    # IssuingWithdrawal struct
  """

  @doc """
  The IssuingWithdrawal structs created in your Workspace return cash from your Issuing balance to your Banking balance.

  ## Parameters (required):
    - `:amount` [integer]: IssuingWithdrawal value in cents. Minimum = 0 (any value will be accepted). ex: 1234 (= R$ 12.34)
    - `:external_id` [string] IssuingWithdrawal external ID. ex: "12345"
    - `:description` [string]: IssuingWithdrawal description. ex: "sending money back"

  ## Parameters (optional):
    - `:tags` [list of strings, default []]: list of strings for tagging. ex: ["tony", "stark"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when IssuingWithdrawal is created. ex: "5656565656565656"
    - `:transaction_id` [string]: Stark Infra ledger transaction ids linked to this IssuingWithdrawal
    - `:issuing_transaction_id` [string]: issuing ledger transaction ids linked to this IssuingWithdrawal
    - `:updated` [DateTime]: latest update DateTime for the IssuingWithdrawal. ex: ~U[2020-3-10 10:30:0:0]
    - `:created` [DateTime]: creation datetime for the IssuingWithdrawal. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :amount,
    :external_id,
    :description
  ]
  defstruct [
    :amount,
    :external_id,
    :description,
    :tags,
    :id,
    :transaction_id,
    :issuing_transaction_id,
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of IssuingWithdrawal structs for creation in the Stark Infra API

  ## Parameters (required):
    - `:withdrawal` [IssuingWithdrawal struct]: IssuingWithdrawal struct to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingWithdrawal struct with updated attributes
  """
  @spec create(
    withdrawal: IssuingWithdrawal.t(),
    user: (Organization.t() | Project.t()) | nil
  ) ::
    {:ok, IssuingWithdrawal.t()} |
    {:error, [Error.t()]}
  def create(withdrawal, options \\ []) do
    Rest.post_single(
      resource(),
      withdrawal,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    withdrawal: IssuingWithdrawal.t(),
    user: (Organization.t() | Project.t()) | nil
  ) :: any
  def create!(withdrawal, options \\ []) do
    Rest.post_single!(
      resource(),
      withdrawal,
      options
    )
  end

  @doc """
  Receive a single IssuingWithdrawal struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingWithdrawal struct with updated attributes
  """
  @spec get(
    id: binary,
    user: (Organization.t() | Project.t()) | nil
  ) ::
    {:ok, [IssuingWithdrawal.t()]} |
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
    user: (Organization.t() | Project.t()) | nil
  ) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(
      resource(),
      id,
      options
    )
  end

  @doc """
  Receive a stream of IssuingWithdrawal structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:external_ids` [list of strings, default []]: external IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingWithdrawals structs with updated attributes
  """
  @spec query(
    limit: integer,
    external_ids: [binary] | [],
    after: Date.t() | binary,
    before: Date.t() | binary,
    tags: [binary],
    user: (Organization.t() | Project.t()) | nil
  ) ::
    {:ok, [IssuingWithdrawal.t()]} |
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
    external_ids: [binary] | [],
    after: Date.t() | binary,
    before: Date.t() | binary,
    tags: [binary],
    user: (Organization.t() | Project.t()) | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of IssuingWithdrawal structs previously created in the Stark Infra API and the cursor to the next page.

  ## Options:
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:external_ids` [list of strings, default []]: external IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingWithdrawal structs with updated attributes
    - cursor to retrieve the next page of IssuingWithdrawal structs
  """
  @spec page(
    limit: integer,
    external_ids: [binary] | [],
    after: Date.t() | binary,
    before: Date.t() | binary,
    tags: [binary],
    user: (Organization.t() | Project.t()) | nil
  ) ::
    {:ok, [IssuingWithdrawal.t()], binary} |
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
    limit: integer,
    external_ids: [binary] | [],
    after: Date.t() | binary,
    before: Date.t() | binary,
    tags: [binary],
    user: (Organization.t() | Project.t()) | nil
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
      "IssuingWithdrawal",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingWithdrawal{
      amount: json[:amount],
      external_id: json[:external_id],
      description: json[:description],
      tags: json[:tags],
      id: json[:id],
      transaction_id: json[:transaction_id],
      issuing_transaction_id: json[:issuing_transaction_id],
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime()
    }
  end
end
