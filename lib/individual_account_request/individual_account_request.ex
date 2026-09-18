defmodule StarkInfra.IndividualAccountRequest do
  alias __MODULE__, as: IndividualAccountRequest
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.API
  alias StarkInfra.IndividualAccountRequest.Address
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IndividualAccountRequest related functions
  """

  @doc """
  An IndividualAccountRequest represents an individual account request. It can be created to
  request the opening of an account for a specific individual by providing their required
  information.
  When you initialize an IndividualAccountRequest, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:name` [string]: individual's full name. ex: "Edward Stark"
    - `:tax_id` [string]: individual's tax ID (CPF). ex: "012.345.678-90"
    - `:address` [IndividualAccountRequest.Address struct or map]: individual's structured residential address. ex: %StarkInfra.IndividualAccountRequest.Address{street: "Rua do Estilo Barroco", number: "648", neighborhood: "Santo Amaro", city: "Sao Paulo", state: "SP", zip_code: "05724005"}
    - `:income` [integer]: individual's income in cents. ex: 1000000 (= R$ 10,000.00)

  ## Parameters (optional):
    - `:birth_date` [Date, DateTime or string, default nil]: individual's birth date. ex: ~D[2012-03-06] or "2012-03-06"
    - `:tags` [list of strings, default nil]: list of strings for reference when searching for IndividualAccountRequests. ex: ["employees", "monthly"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the IndividualAccountRequest is created. ex: "5656565656565656"
    - `:account_type` [string]: type of account requested. Options: "individual", "business"
    - `:flags` [list of maps]: review flags raised by the KYC pipeline, populated once the request is validated. ex: [%{"code" => "individualSanctions", "parameter" => "012.345.678-90"}]
    - `:status` [string]: current status of the IndividualAccountRequest. Options: "created", "processing", "approved", "denied"
    - `:created` [DateTime]: creation datetime for the IndividualAccountRequest. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the IndividualAccountRequest. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :name,
    :tax_id,
    :address,
    :income
  ]
  defstruct [
    :name,
    :tax_id,
    :address,
    :income,
    :birth_date,
    :tags,
    :id,
    :account_type,
    :flags,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of IndividualAccountRequest structs for creation at the Stark Infra API

  ## Parameters (required):
    - `:requests` [list of IndividualAccountRequest structs]: list of IndividualAccountRequest structs to be created in the API. You can send up to 100 IndividualAccountRequest structs in a single request.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IndividualAccountRequest structs with updated attributes
  """
  @spec create(
    requests: [IndividualAccountRequest.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [IndividualAccountRequest.t()]} |
    {:error, [Error.t()]}
  def create(requests, options \\ []) do
    Rest.post(
      resource(),
      requests,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    requests: [IndividualAccountRequest.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(requests, options \\ []) do
    Rest.post!(
      resource(),
      requests,
      options
    )
  end

  @doc """
  Receive a single IndividualAccountRequest struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IndividualAccountRequest struct with updated attributes
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IndividualAccountRequest.t()} |
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
  Receive a stream of IndividualAccountRequest structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: "created", "processing", "denied", "approved"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["employees", "monthly"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IndividualAccountRequest structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [IndividualAccountRequest.t()]} |
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
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 IndividualAccountRequest structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: "created", "processing", "denied", "approved"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["employees", "monthly"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IndividualAccountRequest structs with updated attributes
    - cursor to retrieve the next page of IndividualAccountRequest structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IndividualAccountRequest.t()]}} |
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
    tags: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Update an IndividualAccountRequest by passing id.
  You may send the IndividualAccountRequest to validation by passing 'processing' in the status.

  ## Parameters (required):
    - `:id` [string]: IndividualAccountRequest id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:status` [string, default nil]: status to send the request to validation. Options: "processing"
    - `:name` [string, default nil]: individual's full name. ex: "Edward Stark"
    - `:tax_id` [string, default nil]: individual's tax ID (CPF). ex: "012.345.678-90"
    - `:address` [IndividualAccountRequest.Address struct or map, default nil]: individual's structured residential address. Replaces the stored address as a whole.
    - `:income` [integer, default nil]: individual's income in cents. ex: 1500000 (= R$ 15,000.00)
    - `:birth_date` [Date, DateTime or string, default nil]: individual's birth date. ex: ~D[2012-03-06] or "2012-03-06"
    - `:tags` [list of strings, default nil]: list of strings for reference when searching for IndividualAccountRequests. ex: ["employees", "monthly"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target IndividualAccountRequest with updated attributes
  """
  @spec update(
    id: binary,
    status: binary | nil,
    name: binary | nil,
    tax_id: binary | nil,
    address: Address.t() | map() | nil,
    income: integer | nil,
    birth_date: Date.t() | DateTime.t() | binary | nil,
    tags: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IndividualAccountRequest.t()} |
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
    id: binary,
    status: binary | nil,
    name: binary | nil,
    tax_id: binary | nil,
    address: Address.t() | map() | nil,
    income: integer | nil,
    birth_date: Date.t() | DateTime.t() | binary | nil,
    tags: [binary] | nil,
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
      "IndividualAccountRequest",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IndividualAccountRequest{
      name: json[:name],
      tax_id: json[:tax_id],
      address: json[:address] |> parse_address(),
      income: json[:income],
      birth_date: json[:birth_date] |> Check.date(),
      tags: json[:tags],
      id: json[:id],
      account_type: json[:account_type],
      flags: json[:flags],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end

  defp parse_address(address) when is_map(address) do
    API.from_api_json(address, &Address.resource_maker/1)
  end

  defp parse_address(_address) do
    nil
  end
end
