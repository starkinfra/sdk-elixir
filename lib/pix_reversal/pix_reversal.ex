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
    - `:external_id` [string]: string that must be unique among all your PixReversals. Duplicated external IDs will cause failures. By default, this parameter will block any PixReversal that repeats amount and receiver information on the same date. ex: "my-internal-id-123456"
    - `:end_to_end_id` [string]: central bank's unique transaction ID. ex: "E79457883202101262140HHX553UPqeq"
    - `:reason` [string]: reason why the PixReversal is being reversed. Options are "bankError", "fraud", "chashierError", "customerRequest"

  ## Parameters (optional):
    - `:tags` [list of strings, default nil]: list of strings for reference when searching for PixReversals. ex: ["employees", "monthly"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the PixReversal is created. ex: "5656565656565656".
    - `:return_id` [string]: central bank's unique reversal transaction ID. ex: "D20018183202202030109X3OoBHG74wo".
    - `:bank_code` [string]: code of the bank institution in Brazil. ex: "20018183"
    - `:fee` [string]: fee charged by this PixReversal. ex: 200 (= R$ 2.00)
    - `:status` [string]: current PixReversal status. ex: "registered" or "paid"
    - `:flow` [string]: direction of money flow. ex: "in" or "out"
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
    :bank_code,
    :fee,
    :status,
    :flow,
    :created,
    :updated,
    :tags,
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of PixReversal structs for creation in the Stark Infra API

  ## Parameters (required):
    - `:reversals` [list of PixReversal objects]: list of PixReversal structs to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixReversal structs with updated attributes
  """
  @spec create(
    [PixReversal.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [PixReversal.t()]} |
    {:error, [error: Error.t()]}
  def create(keys, options \\ []) do
    Rest.post(
      resource(),
      keys,
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
  def create!(keys, options \\ []) do
    Rest.post!(
      resource(),
      keys,
      options
    )
  end

  @doc """
  Receive a single PixReversal struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixReversal struct with updated attributes
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
  Receive a stream of PixReversal structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020, 3, 10]
    - `:status` [list of strings, default nil]: filter for status of retrieved objects. Options: “created”, “processing”, “success”, “failed”
    - `:tags` [list of strings, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:return_ids` [list of strings, default nil]: central bank's unique reversal transaction IDs. ex: ["D20018183202202030109X3OoBHG74wo", "D20018183202202030109X3OoBHG72rd"].
    - `:external_ids` [list of strings, default nil]: url safe strings that must be unique among all your PixReversals. Duplicated external IDs will cause failures. By default, this parameter will block any PixReversal that repeats amount and receiver information on the same date. ex: ["my-internal-id-123456", "my-internal-id-654321"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixReversal structs with updated attributes
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
  Receive a list of up to 100 PixReversal structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your reversals.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020, 3, 10]
    - `:status` [list of strings, default nil]: filter for status of retrieved objects. Options: “created”, “processing”, “success”, “failed”
    - `:tags` [list of strings, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:return_ids` [list of strings, default nil]: central bank's unique reversal transaction ID. ex: ["D20018183202202030109X3OoBHG74wo", "D20018183202202030109X3OoBHG72rd"].
    - `:external_ids` [list of strings, default nil]: url safe string that must be unique among all your PixReversals. Duplicated external IDs will cause failures. By default, this parameter will block any PixReversal that repeats amount and receiver information on the same date. ex: ["my-internal-id-123456", "my-internal-id-654321"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixReversal structs with updated attributes
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
  Create a single PixReversal struct from a content string received from a handler listening at the request url.
  If the provided digital signature does not check out with the StarkInfra public key, a
  starkinfra.error.InvalidSignatureError will be raised.

  ## Parameters (required):
    - `:content` [string]: response content from request received at user endpoint (not parsed)
    - `:signature` [string]: base-64 digital signature received at response header "Digital-Signature"

  ## Options:
    - `cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

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
      amount: json[:amount],
      external_id: json[:external_id],
      end_to_end_id: json[:end_to_end_id],
      reason: json[:reason],
      id: json[:id],
      tags: json[:tags],
      return_id: json[:return_id],
      bank_code: json[:bank_code],
      fee: json[:fee],
      status: json[:status],
      flow: json[:flow],
      created:  json[:created] |> Check.datetime(),
      updated:  json[:updated] |> Check.datetime()
    }
  end
end
