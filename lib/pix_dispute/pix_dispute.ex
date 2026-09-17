defmodule StarkInfra.PixDispute do
  alias __MODULE__, as: PixDispute
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.API
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error
  alias StarkInfra.PixDispute.Transaction

  @moduledoc """
  Groups PixDispute related functions
  """

  @doc """
  Pix disputes can be created when a fraud is detected creating a chain of transactions
  in order to reverse the funds to the origin.
  When you initialize a PixDispute, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:reference_id` [string]: endToEndId of the transaction being reported. ex: "E20018183202201201450u34sDGd19lz"
    - `:method` [string]: method used to perform the fraudulent action. Options: "scam", "unauthorized", "coercion", "invasion", "other", "unknown"
    - `:operator_email` [string]: contact email of the operator responsible for the dispute.
    - `:operator_phone` [string]: contact phone number of the operator responsible for the dispute.

  ## Parameters (optional):
    - `:description` [string, default nil]: description including any details that can help with the dispute investigation. Required when `:method` is "other".
    - `:tags` [list of strings, default nil]: list of strings for tagging. ex: ["travel", "food"]
    - `:min_transaction_amount` [integer, default nil]: minimum transaction amount to be considered for the graph creation.
    - `:max_transaction_count` [integer, default nil]: maximum number of transactions to be considered for the graph creation.
    - `:max_hop_interval` [integer, default nil]: maximum interval in seconds between hops to be considered for the graph creation.
    - `:max_hop_count` [integer, default nil]: depth to be considered for the graph creation.

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the PixDispute is created. ex: "5656565656565656"
    - `:bacen_id` [string]: Central Bank's unique dispute id. ex: "817fc523-9e9d-40ab-9e53-dacb71454a05"
    - `:flow` [string]: indicates the flow of the Pix Dispute. Options: "in" if you received the PixDispute, "out" if you created the PixDispute.
    - `:status` [string]: current PixDispute status. Options: "created", "delivered", "analysed", "processing", "closed", "failed", "canceled".
    - `:transactions` [list of PixDispute.Transaction structs]: list of transactions related to the dispute.
    - `:created` [DateTime]: creation datetime for the PixDispute. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the PixDispute. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :reference_id,
    :method,
    :operator_email,
    :operator_phone
  ]
  defstruct [
    :reference_id,
    :method,
    :operator_email,
    :operator_phone,
    :description,
    :tags,
    :min_transaction_amount,
    :max_transaction_count,
    :max_hop_interval,
    :max_hop_count,
    :id,
    :bacen_id,
    :flow,
    :status,
    :transactions,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of PixDispute structs for creation at the Stark Infra API

  ## Parameters (required):
    - `:disputes` [list of PixDispute structs]: list of PixDispute structs to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixDispute structs with updated attributes
  """
  @spec create(
    [PixDispute.t() | map],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [PixDispute.t()]} |
    {:error, [Error.t()]}
  def create(disputes, options \\ []) do
    Rest.post(
      resource(),
      disputes,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    [PixDispute.t() | map],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(disputes, options \\ []) do
    Rest.post!(
      resource(),
      disputes,
      options
    )
  end

  @doc """
  Receive a single PixDispute struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixDispute struct with updated attributes
  """
  @spec get(
    binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, PixDispute.t()} |
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
  Receive a stream of PixDispute structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "closed", "canceled"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:bacen_id` [string, default nil]: Central Bank's unique dispute id to filter retrieved objects. ex: "817fc523-9e9d-40ab-9e53-dacb71454a05"
    - `:reference_ids` [list of strings, default nil]: list of end_to_end_ids of the reported transactions to filter retrieved objects. ex: ["E20018183202201201450u34sDjD7334"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixDispute structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    ids: [binary],
    bacen_id: binary,
    reference_ids: [binary],
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    ({:cont, {:ok, [PixDispute.t()]}} |
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
    ids: [binary],
    bacen_id: binary,
    reference_ids: [binary],
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
  Receive a list of up to 100 PixDispute structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "closed", "canceled"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:bacen_id` [string, default nil]: Central Bank's unique dispute id to filter retrieved objects. ex: "817fc523-9e9d-40ab-9e53-dacb71454a05"
    - `:reference_ids` [list of strings, default nil]: list of end_to_end_ids of the reported transactions to filter retrieved objects. ex: ["E20018183202201201450u34sDjD7334"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixDispute structs with updated attributes
    - cursor to retrieve the next page of PixDispute structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    ids: [binary],
    bacen_id: binary,
    reference_ids: [binary],
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [PixDispute.t()]}} |
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
    bacen_id: binary,
    reference_ids: [binary],
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
  Cancel a PixDispute entity previously created in the Stark Infra API

  ## Parameters (required):
    - `:id` [string]: PixDispute unique id. ex: "6306109539221504"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled PixDispute struct
  """
  @spec cancel(
    binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, PixDispute.t()} |
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
    binary,
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
      "PixDispute",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %PixDispute{
      reference_id: json[:reference_id],
      method: json[:method],
      operator_email: json[:operator_email],
      operator_phone: json[:operator_phone],
      description: json[:description],
      tags: json[:tags],
      min_transaction_amount: json[:min_transaction_amount],
      max_transaction_count: json[:max_transaction_count],
      max_hop_interval: json[:max_hop_interval],
      max_hop_count: json[:max_hop_count],
      id: json[:id],
      bacen_id: json[:bacen_id],
      flow: json[:flow],
      status: json[:status],
      transactions: json[:transactions] && Enum.map(json[:transactions], fn transaction -> API.from_api_json(transaction, &Transaction.resource_maker/1) end),
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
