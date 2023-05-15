defmodule StarkInfra.PixClaim do
  alias __MODULE__, as: PixClaim
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups PixClaim related functions
  """

  @doc """
  PixClaims intend to transfer a PixKey from one account to another.

  When you initialize a PixClaim, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the objects
  to the Stark Infra API and returns the created object.

  ## Parameters (required):
    - `:account_created` [Date, DateTime or binary]: opening Date or DateTime for the account claiming the PixKey. ex: "2022-01-01".
    - `:account_number` [binary]: number of the account claiming the PixKey. ex: "76543".
    - `:account_type` [binary]: type of the account claiming the PixKey. ex: "checking", "savings", "salary" or "payment".
    - `:branch_code` [binary]: branch code of the account claiming the PixKey. ex: 1234".
    - `:name` [binary]: holder's name of the account claiming the PixKey. ex: "Jamie Lannister".
    - `:tax_id` [binary]: holder's taxId of the account claiming the PixKey (CPF/CNPJ). ex: "012.345.678-90".
    - `:key_id` [binary]: id of the registered Pix Key to be claimed. Allowed keyTypes are CPF, CNPJ, phone number or email. ex: "+5511989898989".

  ## Parameters (optional):
    - `:tags` [list of binaries, default []]: list of binaries for tagging. ex: ["travel", "food"]

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the PixClaim is created. ex: "5656565656565656"
    - `:status` [binary]: current PixClaim status. ex: "created", "failed", "delivered", "confirmed", "success", "canceled"
    - `:type` [binary]: type of Pix Claim. ex: "ownership", "portability".
    - `:key_type` [binary]: keyType of the claimed PixKey. ex: "CPF", "CNPJ", "phone" or "email"
    - `:flow` [binary]: direction of the Pix Claim. ex: "in" if you received the PixClaim or "out" if you created the PixClaim.
    - `:claimer_bank_code` [binary]: bank_code of the Pix participant that created the PixClaim. ex: "20018183"
    - `:claimed_bank_code` [binary]: bank_code of the account donating the PixKey. ex: "20018183".
    - `:created` [DateTime]: creation DateTime for the PixClaim. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: update DateTime for the PixClaim. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :account_created,
    :account_number,
    :account_type,
    :branch_code,
    :name,
    :tax_id,
    :key_id
  ]
  defstruct [
    :account_created,
    :account_number,
    :account_type,
    :branch_code,
    :name,
    :tax_id,
    :key_id,
    :id,
    :status,
    :type,
    :key_type,
    :flow,
    :claimer_bank_code,
    :claimed_bank_code,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Create a PixClaim to request the transfer of a PixKey to an account
  hosted at other Pix participants in the Stark Infra API.

  ## Parameters (required):
    - `:claim` [PixClaim object]: PixClaim object to be created in the API.

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixClaim object with updated attributes.
  """
  @spec create(
    PixClaim.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixClaim.t()} |
    {:error, [error: Error.t()]}
  def create(keys, options \\ []) do
    Rest.post_single(
      resource(),
      keys,
      options
    )
  end

  @doc """
  Same as create, but it will unwrap the error tuple and raise in case of error.
  """
  @spec create!(PixClaim.t() | map(), user: Project.t() | Organization.t() | nil) :: any
  def create!(keys, options \\ []) do
    Rest.post_single!(
      resource(),
      keys,
      options
    )
  end

  @doc """
  Retrieve a PixClaim object linked to your Workspace in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixClaim object that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixClaim.t()} |
    {:error, [error: Error.t()]}
  def get(id, options \\ []) do
    Rest.get_id(
      resource(),
      id,
      options
    )
  end

  @doc """
  Same as get, but it will unwrap the error tuple and raise in case of error.
  """
  @spec get!(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(
      resource(),
      id,
      options
    )
  end

  @doc """
  Receive a stream of PixClaim objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or binary, default nil]: date filter for objects created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: "created", "failed", "delivered", "confirmed", "success", "canceled".
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:type` [binaries, default nil]: filter for the type of retrieved PixClaims. ex: "ownership" or "portability".
    - `:key_type` [binary, default nil]: filter for the PixKey type of retrieved PixClaims. ex: "cpf", "cnpj", "phone", "email" and "evp"
    - `:key_id` [binary, default nil]: filter PixClaims linked to a specific PixKey id. ex: "+5511989898989"
    - `:flow` [binary, default nil]: direction of the Pix Claim. ex: "in" if you received the PixClaim or "out" if you created the PixClaim.
    - `:tags` [list of binaries, default nil]: list of binaries to filter retrieved objects. ex: ["travel", "food"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixClaim objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    ids: [binary],
    type: binary,
    key_type: binary,
    key_id: binary,
    flow: binary,
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [PixClaim.t()]} | {:error, [error: Error.t()]}
  def query(options \\ []) do
    Rest.get_list(
      resource(),
      options
    )
  end

  @doc """
  Same as query, but it will unwrap the error tuple and raise in case of error.
  """
  @spec query!(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    ids: [binary],
    type: binary,
    key_type: binary,
    key_id: binary,
    flow: binary,
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 PixClaim objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created after a specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or binary, default nil]: date filter for objects created before a specified date. ex: ~D[2020, 3, 10]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: "created", "failed", "delivered", "confirmed", "success", "canceled"
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:type` [binaries, default nil]: filter for the type of retrieved PixClaims. ex: "ownership" or "portability".
    - `:key_type` [binary, default nil]: filter for the PixKey type of retrieved PixClaims. ex: "cpf", "cnpj", "phone", "email", "evp".
    - `:key_id` [binary, default nil]: filter PixClaims linked to a specific PixKey id. Example: "+5511989898989".
    - `:flow` [binary, default nil]: direction of the Pix Claim. ex: "in" if you received the PixClaim or "out" if you created the PixClaim.
    - `:tags` [list of binaries, default nil]: list of binaries to filter retrieved objects. ex: ["travel", "food"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixClaim objects with updated attributes
    - cursor to retrieve the next page of PixClaim objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    ids: [binary],
    type: binary,
    key_type: binary,
    key_id: binary,
    flow: binary,
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [PixClaim.t()]}} |
    {:error, [error: Error.t()]}
  def page(options \\ []) do
    Rest.get_page(
      resource(),
      options
    )
  end

  @doc """
  Same as page, but it will unwrap the error tuple and raise in case of error.
  """
  @spec page!(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    ids: [binary],
    type: binary,
    key_type: binary,
    key_id: binary,
    flow: binary,
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Update a PixClaim parameters by passing id.

  ## Parameters (required):
    - `:id` [binary]: PixClaim id. ex: '5656565656565656'
    - `:status` [binary]: patched status for Pix Claim. ex: "confirmed" and "canceled"

  ## Parameters (optional):
    - `:reason` [binary, default: "userRequested"]: reason why the PixClaim is being patched. ex: "fraud", "userRequested", "accountClosure"
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixClaim with updated attributes
  """
  @spec update(
    binary,
    status: binary,
    reason: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixClaim.t()} |
    {:error, [error: Error.t()]}
  def update(id, status, parameters \\ []) do
    parameters = [status: status] ++ parameters
    Rest.patch_id(
      resource(),
      id,
      parameters
    )
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of error.
  """
  @spec update!(
    binary,
    status: binary,
    reason: binary,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def update!(id, status, parameters \\ []) do
    parameters = [status: status] ++ parameters
    Rest.patch_id!(
      resource(),
      id,
      parameters
    )
  end

  @doc false
  def resource() do
    {
      "PixClaim",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %PixClaim{
      account_created: json[:account_created] |> Check.datetime(),
      account_number: json[:account_number],
      account_type: json[:account_type],
      branch_code: json[:branch_code],
      name: json[:name],
      tax_id: json[:tax_id],
      key_id: json[:key_id],
      id: json[:id],
      status: json[:status],
      type: json[:type],
      key_type: json[:key_type],
      flow: json[:flow],
      claimer_bank_code: json[:claimer_bank_code],
      claimed_bank_code: json[:claimed_bank_code],
      created:  json[:created] |> Check.datetime(),
      updated:  json[:updated] |> Check.datetime()
    }
  end
end
