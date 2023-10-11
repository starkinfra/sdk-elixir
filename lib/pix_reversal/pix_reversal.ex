defmodule StarkInfra.PixReversal do
  alias __MODULE__, as: PixReversal
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.Utils.Parse
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups PixReversal related functions
  """
  @doc """
  PixReversals are instant payments used to revert PixReversals. You can only
  revert inbound PixReversals.

  When you initialize a PixReversal, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the objects
  to the Stark Infra API and returns the list of created objects.

  ## Parameters (required):
    - `:amount` [integer]: amount in cents to be reversed from the PixReversal. ex: 1234 (= R$ 12.34)
    - `:external_id` [binary]: binary that must be unique among all your PixReversals. Duplicated external IDs will cause failures. By default, this parameter will block any PixReversal that repeats amount and receiver information on the same date. ex: "my-internal-id-123456"
    - `:end_to_end_id` [binary]: central bank's unique transaction ID. ex: "E79457883202101262140HHX553UPqeq"
    - `:reason` [binary]: reason why the PixReversal is being reversed. Options are "bankError", "fraud", "cashierError", "customerRequest"

  ## Parameters (optional):
    - `:tags` [list of binaries, default []]: list of binaries for reference when searching for PixReversals. ex: ["employees", "monthly"]

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the PixReversal is created. ex: "5656565656565656".
    - `:return_id` [binary]: central bank's unique reversal transaction ID. ex: "D20018183202202030109X3OoBHG74wo".
    - `:fee` [binary]: fee charged by this PixReversal. ex: 200 (= R$ 2.00)
    - `:status` [binary]: current PixReversal status. ex: "created", "processing", "success", "failed"
    - `:flow` [binary]: direction of money flow. ex: "in" or "out"
    - `:created` [DateTime]: creation datetime for the PixReversal. ex: ~U[2020-03-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the PixReversal. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :amount,
    :external_id,
    :end_to_end_id,
    :reason
  ]
  defstruct [
    :amount,
    :external_id,
    :end_to_end_id,
    :reason,
    :id,
    :return_id,
    :fee,
    :status,
    :flow,
    :created,
    :updated,
    :tags,
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of PixReversal objects for creation in the Stark Infra API

  ## Parameters (required):
    - `:reversals` [list of PixReversal objects]: list of PixReversal objects to be created in the API

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixReversal objects with updated attributes
  """
  @spec create(
    [PixReversal.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [PixReversal.t()]} |
    {:error, [error: Error.t()]}
  def create(reversals, options \\ []) do
    Rest.post(
      resource(),
      reversals,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    [PixReversal.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [PixReversal.t()]} |
    {:error, [error: Error.t()]}
  def create!(reversals, options \\ []) do
    Rest.post!(
      resource(),
      reversals,
      options
    )
  end

  @doc """
  Receive a single PixReversal object previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixReversal object that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixReversal.t()} |
    {:error, [error: Error.t()]}
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
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixReversal.t()} |
    {:error, [error: Error.t()]}
  def get!(id, options \\ []) do
    Rest.get_id!(
      resource(),
      id,
      options
    )
  end

  @doc """
  Receive a stream of PixReversal objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created after a specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or binary, default nil]: date filter for objects created before a specified date. ex: ~D[2020, 3, 10]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: “created”, “processing”, “success”, “failed”
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:return_ids` [list of binaries, default nil]: central bank's unique reversal transaction IDs. ex: ["D20018183202202030109X3OoBHG74wo", "D20018183202202030109X3OoBHG72rd"].
    - `:external_ids` [list of binaries, default nil]: url safe binaries that must be unique among all your PixReversals. Duplicated external IDs will cause failures. By default, this parameter will block any PixReversal that repeats amount and receiver information on the same date. ex: ["my-internal-id-123456", "my-internal-id-654321"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixReversal objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    return_ids: [binary],
    external_ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixReversal.t()} |
    {:error, [error: Error.t()]}
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
    return_ids: [binary],
    external_ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixReversal.t()} |
    {:error, [error: Error.t()]}
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 PixReversal objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your reversals.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created after a specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or binary, default nil]: date filter for objects created before a specified date. ex: ~D[2020, 3, 10]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: “created”, “processing”, “success”, “failed”
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:return_ids` [list of binaries, default nil]: central bank's unique reversal transaction ID. ex: ["D20018183202202030109X3OoBHG74wo", "D20018183202202030109X3OoBHG72rd"].
    - `:external_ids` [list of binaries, default nil]: url safe binary that must be unique among all your PixReversals. Duplicated external IDs will cause failures. By default, this parameter will block any PixReversal that repeats amount and receiver information on the same date. ex: ["my-internal-id-123456", "my-internal-id-654321"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixReversal objects with updated attributes
    - cursor to retrieve the next page of PixReversal objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    return_ids: [binary],
    external_ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixReversal.t()} |
    {:error, [error: Error.t()]}
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
    return_ids: [binary],
    external_ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixReversal.t()} |
    {:error, [error: Error.t()]}
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Create a single PixReversal object from a content binary received from a handler listening at the request url.
  If the provided digital signature does not check out with the StarkInfra public key, a
  starkinfra.error.InvalidSignatureError will be raised.

  ## Parameters (required):
    - `:content` [binary]: response content from request received at user endpoint (not parsed)
    - `:signature` [binary]: base-64 digital signature received at response header "Digital-Signature"

  ## Parameters (optional):
    - `cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Parsed PixReversal object
  """
  @spec parse(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  )::
    {:ok, PixReversal.t()} |
    {:error, [error: Error.t()]}
  def parse(options \\ []) do
    %{content: content, signature: signature, cache_pid: cache_pid, user: user} =
    Enum.into(
      options |> Check.enforced_keys([:content, :signature]),
      %{cache_pid: nil, user: nil}
    )
    Parse.parse_and_verify(
      content: content,
      signature: signature,
      cache_pid: cache_pid,
      key: nil,
      resource_maker:  &resource_maker/1,
      user: user
    )
  end

  @doc """
  Same as parse(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  ) :: any
  def parse!(options \\ []) do
    %{content: content, signature: signature, cache_pid: cache_pid, user: user} =
      Enum.into(
        options |> Check.enforced_keys([:content, :signature]),
        %{cache_pid: nil, user: nil}
      )
    Parse.parse_and_verify(
      content: content,
      signature: signature,
      cache_pid: cache_pid,
      key: nil,
      resource_maker:  &resource_maker/1,
      user: user
    )

  end

  @doc """
  Helps you respond to a PixReversal authorization

  ## Parameters (required):
    - `:status` [binary]: response to the authorization. ex: "approved" or "denied"

  ## Parameters (conditionally-required):
    - `:reason` [binary, default nil]: denial reason. Required if the status is "denied". Options: "invalidAccountNumber", "blockedAccount", "accountClosed", "invalidAccountType", "invalidTransactionType", "taxIdMismatch", "invalidTaxId", "orderRejected", "reversalTimeExpired", "settlementFailed"

    ## Return:
    - Dumped JSON binary that must be returned to us
  """

  @spec response(
    map(),
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixReversal.t()} |
    {:error, [Error.t()]}
  def response(status, reason) do
    body = %{status: status, reason: reason}
    params = %{authorization: body}
    params
    |> Jason.encode!
  end

  @doc false
  def resource() do
    {
      "PixReversal",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %PixReversal{
      id: json[:id],
      amount: json[:amount],
      external_id: json[:external_id],
      end_to_end_id: json[:end_to_end_id],
      reason: json[:reason],
      tags: json[:tags],
      return_id: json[:return_id],
      fee: json[:fee],
      status: json[:status],
      flow: json[:flow],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
