defmodule StarkInfra.PixKey do
  alias __MODULE__, as: PixKey
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups PixKey related functions
  """

  @doc """
  PixKeys link bank account information to key ids.
  Key ids are a convenient way to search and pass bank account information.
  When you initialize a Pix Key, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:account_created` [Date, DateTime or string]: opening Date or DateTime for the linked account. ex: "2022-01-01".
    - `:account_number` [string]: number of the linked account. ex: "76543".
    - `:account_type` [string]: type of the linked account. Options: "checking", "savings", "salary" or "payment".
    - `:branch_code` [string]: branch code of the linked account. ex: 1234.
    - `:name` [string]: holder's name of the linked account. ex: "Jamie Lannister".
    - `:tax_id` [string]: holder's taxId (CPF/CNPJ) of the linked account. ex: "012.345.678-90".

  ## Parameters (optional):
    - `:id` [string, default nil]: id of the registered PixKey. Allowed types are: CPF, CNPJ, phone number or email. If this parameter is not passed, an EVP will be created. ex: "+5511989898989";
    - `:tags` [list of strings, default nil]: list of strings for reference when searching for PixKeys. ex: ["employees", "monthly"]

  ## Attributes (return-only):
    - `:owned` [DateTime]: datetime when the key was owned by the holder. ex: ~U[2020-3-10 10:30:0:0]
    - `:owner_type` [string]: type of the owner of the PixKey. Options: "business" or "individual".
    - `:status` [string]: current PixKey status. Options: "created", "registered", "canceled", "failed"
    - `:bank_code` [string]: bank_code of the account linked to the Pix Key. ex: "20018183".
    - `:bank_name` [string]: name of the bank that holds the account linked to the PixKey. ex: "StarkBank"
    - `:type` [string]: type of the PixKey. Options: "cpf", "cnpj", "phone", "email" and "evp",
    - `:created` [DateTime]: creation datetime for the PixKey. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :account_created,
    :account_number,
    :account_type,
    :branch_code,
    :name,
    :tax_id
  ]
  defstruct [
    :account_created,
    :account_number,
    :account_type,
    :branch_code,
    :name,
    :tax_id,
    :id,
    :tags,
    :owned,
    :owner_type,
    :status,
    :bank_code,
    :bank_name,
    :type,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Create a PixKey linked to a specific account in the Stark Infra API

  ## Options:
    - `:key` [PixKey struct]: PixKey struct to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixKey struct with updated attributes.
  """
  @spec create(
    PixKey.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixKey.t()} |
    {:error, [error: Error.t()]}
  def create(keys, options \\ []) do
    Rest.post_single(
      resource(),
      keys,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    PixKey.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(keys, options \\ []) do
    Rest.post_single!(
      resource(),
      keys,
      options
    )
  end

  @doc """
  Retrieve the PixKey struct linked to your Workspace in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656".
    - `:payer_id` [string]: tax id (CPF/CNPJ) of the individual or business requesting the PixKey information. This id is used by the Central Bank to limit request rates. ex: "20.018.183/0001-80".

  ## Options:
    - `:end_to_end_id` [string, default nil]: central bank's unique transaction id. If the request results in the creation of a PixRequest, the same endToEndId should be used. If this parameter is not passed, one endToEndId will be automatically created. Example: "E00002649202201172211u34srod19le"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixKey struct that corresponds to the given id.
  """
  @spec get(
    binary,
    payer_id: binary,
    end_to_end_id: binary | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixKey.t()} |
    {:error, [error: Error.t()]}
  def get(id, payer_id, options \\ []) do
    options = [payer_id: payer_id] ++ options
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(
    binary,
    payer_id: binary,
    end_to_end_id: binary | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def get!(id, payer_id, options \\ []) do
    options = [payer_id: payer_id] ++ options
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of PixKeys structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020, 3, 10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: "created", "registered", "canceled", "failed".
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:type` [list of strings, default nil]: filter for the type of retrieved PixKeys. Options: "cpf", "cnpj", "phone", "email", "evp".
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixKey structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t(),
    before: Date.t(),
    status: binary,
    tags: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, [PixKey.t()]} |
    {:error, [Error.t()]},
    any -> any)
  def query(options \\ []) do
    Rest.get_list(resource(), options)
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
    limit: integer,
    after: Date.t(),
    before: Date.t(),
    status: binary,
    tags: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a stream of PixKeys structs previously created in the Stark Infra API

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020, 3, 10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: "created", "failed", "delivered", "confirmed", "success", "canceled"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:type` [list of strings, default nil]: filter for the type of retrieved PixKeys. Options: "cpf", "cnpj", "phone", "email", "evp".
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - cursor to retrieve the next page of PixKey structs
    - stream of PixKey structs with updated attributes
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    tags: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {:binary, [PixKey.t()]}} |
    { :error, [error: Error.t()]}
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    tags: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Update a PixKey parameters by passing id.

  ## Parameters (required):
    - `:id` [string]: PixKey id. ex: '5656565656565656'
    - `:reason` [string]: reason why the PixKey is being patched. Options: "branchTransfer", "reconciliation" or "userRequested".

  ## Parameters (optional):
    - `:account_created` [Date, DateTime or string, default nil]: opening Date or DateTime for the account to be linked. ex: "2022-01-01.
    - `:account_number` [string, default nil]: number of the account to be linked. ex: "76543".
    - `:account_type` [string, default nil]: type of the account to be linked. Options: "checking", "savings", "salary" or "payment".
    - `:branch_code` [string, default nil]: branch code of the account to be linked. ex: 1234".
    - `:name` [string, default nil]: holder's name of the account to be linked. ex: "Jamie Lannister".

  ## Return:
    - PixKey with updated attributes
  """
  @spec update(
    binary,
    reason: binary,
    account_created: Date.t(),
    account_number: binary,
    account_type: binary,
    branch_code: binary,
    name: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixKey.t()} |
    {:error, [error: Error.t()]}
  def update(id, reason, parameters \\ []) do
    parameters = [reason: reason] ++ parameters
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
    binary,
    reason: binary,
    account_created: Date.t(),
    account_number: binary,
    account_type: binary,
    branch_code: binary,
    name: binary,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def update!(id, reason, parameters \\ []) do
    parameters = [reason: reason] ++ parameters
    Rest.patch_id!(
      resource(),
      id,
      parameters
    )
  end

  @doc """
  Delete a pixKey entity previously created in the Stark Infra API

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled pixKey struct
  """
  @spec cancel(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [PixKey.t()] } |
    {:error, [error: Error.t()]}
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
    user: Project.t() | Organization.t() | nil
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
      "PixKey",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %PixKey{
      account_created: json[:account_created] |> Check.datetime(),
      account_number: json[:account_number],
      account_type: json[:account_type],
      branch_code: json[:branch_code],
      name: json[:name],
      tax_id: json[:tax_id],
      id: json[:id],
      tags: json[:tags],
      owned: json[:owned] |> Check.datetime(),
      owner_type: json[:owner_type],
      status: json[:status],
      bank_code: json[:bank_code],
      bank_name: json[:bank_name],
      type: json[:type],
      created: json[:created] |> Check.datetime()
    }
  end
end
