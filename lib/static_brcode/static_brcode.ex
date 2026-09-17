defmodule StarkInfra.StaticBrcode do
  alias __MODULE__, as: StaticBrcode
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups StaticBrcode related functions
  """

  @doc """
  A StaticBrcode stores account information in the form of a PixKey and can be used to create
  Pix transactions easily.
  When you initialize a StaticBrcode, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:name` [string]: receiver's name. ex: "Tony Stark"
    - `:key_id` [string]: receiver's PixKey id. ex: "+5541999999999"
    - `:city` [string]: receiver's city name. ex: "Rio de Janeiro"

  ## Parameters (optional):
    - `:amount` [integer, default 0]: positive integer that represents the amount in cents of the resulting Pix transaction. ex: 1234 (= R$ 12.34)
    - `:cashier_bank_code` [string, default nil]: Cashier's bank code. ex: "20018183".
    - `:reconciliation_id` [string, default nil]: id to be used for conciliation of the resulting Pix transaction. This id must have up to 25 alphanumeric characters ex: "ah27s53agj6493hjds6836v49"
    - `:description` [string, default nil]: optional description to override default description to be shown in the bank statement. ex: "Payment for service #1234"
    - `:tags` [list of strings, default []]: list of strings for tagging. ex: ["travel", "food"]
    - `:type` [string, default "instant"]: type of the StaticBrcode. Options: "instant", "instantAndOrSubscription"

  ## Attributes (return-only):
    - `:id` [string]: id returned on creation, this is the BR code. ex: "00020126360014br.gov.bcb.pix0114+552840092118152040000530398654040.095802BR5915Jamie Lannister6009Sao Paulo620705038566304FC6C"
    - `:uuid` [string]: unique uuid returned when a StaticBrcode is created. ex: "97756273400d42ce9086404fe10ea0d6"
    - `:url` [string]: url link to the BR code image. ex: "https://brcode-h.development.starkinfra.com/static-qrcode/97756273400d42ce9086404fe10ea0d6.png"
    - `:created` [DateTime]: creation datetime for the StaticBrcode. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the StaticBrcode. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :name,
    :key_id,
    :city
  ]
  defstruct [
    :name,
    :key_id,
    :city,
    :amount,
    :cashier_bank_code,
    :reconciliation_id,
    :description,
    :tags,
    :type,
    :id,
    :uuid,
    :url,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of StaticBrcode structs for creation at the Stark Infra API

  ## Parameters (required):
    - `:brcodes` [list of StaticBrcode structs]: list of StaticBrcode structs to be created in the API. You can send up to 100 StaticBrcode structs in a single request.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of StaticBrcode structs with updated attributes
  """
  @spec create(
    brcodes: [StaticBrcode.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [StaticBrcode.t()]} |
    {:error, Error.t()}
  def create(brcodes, options \\ []) do
    Rest.post(
      resource(),
      brcodes,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    brcodes: [StaticBrcode.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(brcodes, options \\ []) do
    Rest.post!(
      resource(),
      brcodes,
      options
    )
  end

  @doc """
  Retrieve a single StaticBrcode struct previously created in the Stark Infra API by its uuid

  ## Parameters (required):
    - `:uuid` [string]: struct's unique uuid. ex: "97756273400d42ce9086404fe10ea0d6"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - StaticBrcode struct with updated attributes
  """
  @spec get(
    uuid: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, StaticBrcode.t()} |
    {:error, Error.t()}
  def get(uuid, options \\ []) do
    Rest.get_id(
      resource(),
      uuid,
      options
    )
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(
    uuid: binary,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def get!(uuid, options \\ []) do
    Rest.get_id!(
      resource(),
      uuid,
      options
    )
  end

  @doc """
  Receive a stream of StaticBrcode structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:uuids` [list of strings, default nil]: list of uuids to filter retrieved structs. ex: ["97756273400d42ce9086404fe10ea0d6", "e3da0b6d56fa4045b9b295b2be82436e"]
    - `:tags` [list of strings, default nil]: list of tags to filter retrieved structs. ex: ["travel", "food"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of StaticBrcode structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    uuids: [binary],
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [StaticBrcode.t()]} |
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
    uuids: [binary],
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
  Receive a list of up to 100 StaticBrcode structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:uuids` [list of strings, default nil]: list of uuids to filter retrieved structs. ex: ["97756273400d42ce9086404fe10ea0d6", "e3da0b6d56fa4045b9b295b2be82436e"]
    - `:tags` [list of strings, default nil]: list of tags to filter retrieved structs. ex: ["travel", "food"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of StaticBrcode structs with updated attributes
    - cursor to retrieve the next page of StaticBrcode structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    uuids: [binary],
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [StaticBrcode.t()]}} |
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
    uuids: [binary],
    tags: [binary],
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
      "StaticBrcode",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %StaticBrcode{
      name: json[:name],
      key_id: json[:key_id],
      city: json[:city],
      amount: json[:amount],
      cashier_bank_code: json[:cashier_bank_code],
      reconciliation_id: json[:reconciliation_id],
      description: json[:description],
      tags: json[:tags],
      type: json[:type],
      id: json[:id],
      uuid: json[:uuid],
      url: json[:url],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime(),
    }
  end
end
