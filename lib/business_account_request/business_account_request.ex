defmodule StarkInfra.BusinessAccountRequest do
  alias __MODULE__, as: BusinessAccountRequest
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.API
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error
  alias StarkInfra.BusinessAccountRequest.Address
  alias StarkInfra.BusinessAccountRequest.Owner

  @moduledoc """
  Groups BusinessAccountRequest related functions
  """

  @doc """
  You can create a BusinessAccountRequest to request an account for a specific company, opening
  the account with identity verification by webview for each of its owners.
  When you initialize a BusinessAccountRequest, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:address` [BusinessAccountRequest.Address struct or map]: company's structured address. ex: %StarkInfra.BusinessAccountRequest.Address{street: "Av. Faria Lima", number: "2000", neighborhood: "Itaim Bibi", city: "Sao Paulo", state: "SP", zip_code: "04538-132"}
    - `:revenue` [integer]: company's annual revenue in cents. ex: 100000000 (= R$ 1,000,000.00)
    - `:name` [string]: company's legal name (minimum 5 characters). ex: "Stark Bank S.A."
    - `:tax_id` [string]: company's tax ID (CNPJ). ex: "20.018.183/0001-80"
    - `:owners` [list of BusinessAccountRequest.Owner structs or maps]: list of 1 to 10 company owners. ex: [%StarkInfra.BusinessAccountRequest.Owner{tax_id: "012.345.678-90", name: "Jamie Lannister", role: "partner"}]

  ## Parameters (optional):
    - `:tags` [list of strings, default nil]: list of strings for reference when searching for BusinessAccountRequests. ex: ["employees", "monthly"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the BusinessAccountRequest is created. ex: "5656565656565656"
    - `:account_type` [string]: type of the account. ex: "business"
    - `:flags` [list of maps]: flags that motivated the decision, populated when the request is denied. Each flag has a code and a message.
    - `:status` [string]: current status of the BusinessAccountRequest. Options: "created", "processing", "approved", "denied"
    - `:created` [DateTime]: creation datetime for the BusinessAccountRequest. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the BusinessAccountRequest. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :address,
    :revenue,
    :name,
    :tax_id,
    :owners
  ]
  defstruct [
    :address,
    :revenue,
    :name,
    :tax_id,
    :owners,
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
  Send a list of BusinessAccountRequest structs for creation in the Stark Infra API

  ## Parameters (required):
    - `:requests` [list of BusinessAccountRequest structs]: list of BusinessAccountRequest structs to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of BusinessAccountRequest structs with updated attributes
  """
  @spec create(
    requests: [BusinessAccountRequest.t() | map],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [BusinessAccountRequest.t()]} |
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
    requests: [BusinessAccountRequest.t() | map],
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
  Receive a single BusinessAccountRequest struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - BusinessAccountRequest struct with updated attributes
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, BusinessAccountRequest.t()} |
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
  Receive a stream of BusinessAccountRequest structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "processing", "approved", "denied"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["breaking", "bad"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of BusinessAccountRequest structs with updated attributes
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
    {:ok, [BusinessAccountRequest.t()]} |
    {:error, Error.t()}
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
  Receive a list of up to 100 BusinessAccountRequest structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "processing", "approved", "denied"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["breaking", "bad"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of BusinessAccountRequest structs with updated attributes
    - cursor to retrieve the next page of BusinessAccountRequest structs
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
    {:ok, {binary, [BusinessAccountRequest.t()]}} |
    {:error, Error.t()}
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

  @doc false
  def resource() do
    {
      "BusinessAccountRequest",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %BusinessAccountRequest{
      address: json[:address] && API.from_api_json(json[:address], &Address.resource_maker/1),
      revenue: json[:revenue],
      name: json[:name],
      tax_id: json[:tax_id],
      owners: json[:owners] && Enum.map(json[:owners], fn owner -> API.from_api_json(owner, &Owner.resource_maker/1) end),
      tags: json[:tags],
      id: json[:id],
      account_type: json[:account_type],
      flags: json[:flags],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime(),
    }
  end
end
