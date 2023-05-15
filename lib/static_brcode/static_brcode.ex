defmodule StarkInfra.StaticBrcode do
  alias __MODULE__, as: StaticBrcode
  alias StarkInfra.Error
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization

  @moduledoc """
  Groups StaticBrcode related functions
  """

  @doc """
  A StaticBrcode stores account information in the form of a PixKey and can be used to create
  Pix transactions easily.

  When you initialize a StaticBrcode, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the objects
  to the Stark Infra API and returns the created object.

  ## Parameters (required):
    - `:name` [binary]: receiver's name. ex: "Tony Stark"
    - `:key_id` [binary]: receiver's Pix key id. ex: "+5541999999999"
    - `:city` [binary]: receiver's city name. ex: "Rio de Janeiro"

  ## Parameters (optional):
    - `:amount` [integer, default 0]: positive integer that represents the amount in cents of the resulting Pix transaction. ex: 1234 (= R$ 12.34)
    - `:reconciliation_id` [binary, default nil]: id to be used for conciliation of the resulting Pix transaction. This id must have up to 25 alphanumeric digits ex: "ah27s53agj6493hjds6836v49"
    - `:cashier_bank_code` [binary, default nil]: cashier's bank code. ex: "20018183".
    - `:description` [binary, default nil]: optional description to override default description to be shown in the bank statement. ex: "Payment for service #1234"
    - `:tags` [list of binaries, default []]: list of binaries for tagging. ex: ["travel", "food"]

  ## Attributes (return-only):
    - `:id` [binary]: id returned on creation, this is the BR Code. ex: "00020126360014br.gov.bcb.pix0114+552840092118152040000530398654040.095802BR5915Jamie Lannister6009Sao Paulo620705038566304FC6C"
    - `:uuid` [binary]: unique uuid returned when a StaticBrcode is created. ex: "97756273400d42ce9086404fe10ea0d6"
    - `:url` [binary]: url link to the BR Code image. ex: "https://brcode-h.development.starkinfra.com/static-qrcode/97756273400d42ce9086404fe10ea0d6.png"
    - `:created` [DateTime]: creation DateTime for the StaticBrcode. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update DateTime for the StaticBrcode. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :name,
    :key_id,
    :city,
  ]
  defstruct [
    :name,
    :key_id,
    :city,
    :amount,
    :reconciliation_id,
    :cashier_bank_code,
    :description,
    :tags,
    :id,
    :uuid,
    :url,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of StaticBrcode objects for creation at the Stark Infra API

  ## Parameters (required):
    - `:brcodes` [list of StaticBrcode objects]: list of StaticBrcode objects to be created in the API.

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of StaticBrcode objects with updated attributes
  """
  @spec create(
    [StaticBrcode.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [StaticBrcode.t()]} |
    {:error, [Error.t()]}
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
    [StaticBrcode.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(brcodes, options \\ []) do
    Rest.post!(
      resource(),
      brcodes,
      options
    )
  end

  @doc """
  Receive a single StaticBrcode object previously created in the Stark Infra API by its uuid

  ## Parameters (required):
    - `:uuid` [binary]: object's unique uuid. ex: "901e71f2447c43c886f58366a5432c4b"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - StaticBrcode object that corresponds to the given uuid.
  """
  @spec get(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [StaticBrcode.t()]} |
    {:error, [Error.t()]}
  def get(uuid, options \\ []) do
    Rest.get_id(resource(), uuid, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: any
  def get!(uuid, options \\ []) do
    Rest.get_id!(resource(), uuid, options)
  end

  @doc """
  Receive a stream of StaticBrcode objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020, 3, 10]
    - `:uuids` [list of binaries, default nil]: list of uuids to filter retrieved objects. ex: ["901e71f2447c43c886f58366a5432c4b", "4e2eab725ddd495f9c98ffd97440702d"]
    - `:tags` [list of binaries, default nil]: list of tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of StaticBrcode objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    uuids: [binary],
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, {:ok, [StaticBrcode.t()]}} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query(options \\ []) do
    Rest.get_list(resource(), options)
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
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, [StaticBrcode.t()]} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of StaticBrcode objects previously created in the Stark Infra API and the cursor to the next page.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020, 3, 10]
    - `:uuids` [list of binaries, default nil]: list of uuids to filter retrieved objects. ex: ["901e71f2447c43c886f58366a5432c4b", "4e2eab725ddd495f9c98ffd97440702d"]
    - `:tags` [list of binaries, default nil]: list of tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
    - list of StaticBrcode objects with updated attributes
    - cursor to retrieve the next page of StaticBrcode objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    uuids: [binary],
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [StaticBrcode.t()]}} |
    {:error, [Error.t()]}
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
    uuids: [binary],
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    [StaticBrcode.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
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
      reconciliation_id: json[:reconciliation_id],
      cashier_bank_code: json[:cashier_bank_code],
      description: json[:description],
      tags: json[:tags],
      id: json[:id],
      uuid: json[:uuid],
      url: json[:url],
      created: json[:created],
      updated: json[:updated]
    }
  end
end
