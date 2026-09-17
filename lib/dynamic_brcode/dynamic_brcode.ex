defmodule StarkInfra.DynamicBrcode do
  alias __MODULE__, as: DynamicBrcode
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.Parse
  alias StarkInfra.Utils.JSON
  alias StarkInfra.Utils.API
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups DynamicBrcode related functions
  """

  @doc """
  BR codes store information represented by Pix QR Codes, which are used to
  send or receive Pix transactions in a convenient way.
  DynamicBrcodes represent charges with information that can change at any time,
  since all data needed for the payment is requested dynamically to an URL stored
  in the BR Code. Stark Infra will receive the GET request and forward it to your
  registered endpoint with a GET request containing the UUID of the BR code for
  identification.
  When you initialize a DynamicBrcode, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:name` [string]: receiver's name. ex: "Tony Stark"
    - `:city` [string]: receiver's city name. ex: "Rio de Janeiro"
    - `:external_id` [string]: string that must be unique among all your DynamicBrcodes. Duplicated external ids will cause failures. ex: "my-internal-id-123456"

  ## Parameters (optional):
    - `:type` [string, default "instant"]: type of the DynamicBrcode. Options: "instant", "due", "subscription", "subscriptionAndInstant", "dueAndOrSubscription"
    - `:tags` [list of strings, default []]: list of strings for tagging. ex: ["travel", "food"]

  ## Attributes (return-only):
    - `:id` [string]: id returned on creation, this is the BR code. ex: "00020126360014br.gov.bcb.pix0114+552840092118152040000530398654040.095802BR5915Jamie Lannister6009Sao Paulo620705038566304FC6C"
    - `:uuid` [string]: unique uuid returned when the DynamicBrcode is created. ex: "4e2eab725ddd495f9c98ffd97440702d"
    - `:url` [string]: url link to the BR code image. ex: "https://brcode-h.development.starkinfra.com/dynamic-qrcode/901e71f2447c43c886f58366a5432c4b.png"
    - `:created` [DateTime]: creation datetime for the DynamicBrcode. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the DynamicBrcode. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :name,
    :city,
    :external_id
  ]
  defstruct [
    :name,
    :city,
    :external_id,
    :type,
    :tags,
    :id,
    :uuid,
    :url,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of DynamicBrcode structs for creation at the Stark Infra API

  ## Parameters (required):
    - `:brcodes` [list of DynamicBrcode structs]: list of DynamicBrcode structs to be created in the API. You can send up to 100 DynamicBrcode structs in a single request.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of DynamicBrcode structs with updated attributes
  """
  @spec create(
    brcodes: [DynamicBrcode.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [DynamicBrcode.t()]} |
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
    brcodes: [DynamicBrcode.t() | map()],
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
  Retrieve a single DynamicBrcode struct previously created in the Stark Infra API by its uuid

  ## Parameters (required):
    - `:uuid` [string]: struct's unique uuid. ex: "901e71f2447c43c886f58366a5432c4b"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - DynamicBrcode struct with updated attributes
  """
  @spec get(
    uuid: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, DynamicBrcode.t()} |
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
  Receive a stream of DynamicBrcode structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:external_id` [string, default nil]: external ID to filter retrieved structs. ex: "my-internal-id-123456"
    - `:uuids` [list of strings, default nil]: list of uuids to filter retrieved structs. ex: ["901e71f2447c43c886f58366a5432c4b", "4e2eab725ddd495f9c98ffd97440702d"]
    - `:tags` [list of strings, default nil]: list of tags to filter retrieved structs. ex: ["travel", "food"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of DynamicBrcode structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    external_id: binary,
    uuids: [binary],
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [DynamicBrcode.t()]} |
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
    external_id: binary,
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
  Receive a list of up to 100 DynamicBrcode structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:external_id` [string, default nil]: external ID to filter retrieved structs. ex: "my-internal-id-123456"
    - `:uuids` [list of strings, default nil]: list of uuids to filter retrieved structs. ex: ["901e71f2447c43c886f58366a5432c4b", "4e2eab725ddd495f9c98ffd97440702d"]
    - `:tags` [list of strings, default nil]: list of tags to filter retrieved structs. ex: ["travel", "food"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of DynamicBrcode structs with updated attributes
    - cursor to retrieve the next page of DynamicBrcode structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    external_id: binary,
    uuids: [binary],
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [DynamicBrcode.t()]}} |
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
    external_id: binary,
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

  @doc """
  Verify a DynamicBrcode Read.

  When a DynamicBrcode is read by your user, a GET request will be made to your registered URL to
  retrieve additional information needed to complete the transaction.
  Use this method to verify the authenticity of a GET request received at your registered endpoint.
  If the provided digital signature does not check out with the StarkInfra public key,
  the returned error will have code "invalidSignature".

  ## Parameters (required):
    - `:uuid` [string]: unique uuid returned when a DynamicBrcode is created. ex: "4e2eab725ddd495f9c98ffd97440702d"
    - `:signature` [string]: base-64 digital signature received at response header "Digital-Signature"

  ## Options:
    - `:cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - verified DynamicBrcode's uuid
  """
  @spec verify(
    uuid: binary,
    signature: binary,
    cache_pid: PID,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, binary} |
    {:error, [Error.t()]}
  def verify(options \\ []) do
    %{uuid: uuid, signature: signature, cache_pid: cache_pid, user: user} =
      Enum.into(
        options |> Check.enforced_keys([:uuid, :signature]),
        %{cache_pid: nil, user: nil}
      )

    Parse.verify(
      content: uuid,
      signature: signature,
      cache_pid: cache_pid,
      user: user
    )
  end

  @doc """
  Same as verify(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec verify!(
    uuid: binary,
    signature: binary,
    cache_pid: PID,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def verify!(options \\ []) do
    %{uuid: uuid, signature: signature, cache_pid: cache_pid, user: user} =
      Enum.into(
        options |> Check.enforced_keys([:uuid, :signature]),
        %{cache_pid: nil, user: nil}
      )

    Parse.verify!(
      content: uuid,
      signature: signature,
      cache_pid: cache_pid,
      user: user
    )
  end

  @doc """
  Helps you respond to a due DynamicBrcode Read.

  When a Due DynamicBrcode is read by your user, a GET request containing the Brcode's
  UUID will be made to your registered URL to retrieve additional information needed
  to complete the transaction.
  The GET request must be answered in the following format, within 5 seconds, and with
  an HTTP status code 200.

  ## Parameters (required):
    - `:version` [integer]: integer that represents how many times the BR code was updated.
    - `:created` [DateTime or string]: creation datetime in ISO format of the DynamicBrcode. ex: ~U[2020-3-10 10:30:0:0]
    - `:due` [DateTime or string]: requested payment due datetime in ISO format. ex: ~U[2020-3-10 10:30:0:0]
    - `:key_id` [string]: receiver's PixKey id. Can be a tax_id (CPF/CNPJ), a phone number, an email or an alphanumeric sequence (EVP). ex: "+5511989898989"
    - `:status` [string]: BR code status. Options: "created", "overdue", "paid", "canceled" or "expired"
    - `:reconciliation_id` [string]: id to be used for conciliation of the resulting Pix transaction. This id must have from to 26 to 35 alphanumeric characters ex: "cd65c78aeb6543eaaa0170f68bd741ee"
    - `:nominal_amount` [integer]: positive integer that represents the amount in cents of the resulting Pix transaction. ex: 1234 (= R$ 12.34)
    - `:sender_name` [string]: sender's full name. ex: "Anthony Edward Stark"
    - `:sender_tax_id` [string]: sender's CPF (11 digits formatted or unformatted) or CNPJ (14 digits formatted or unformatted). ex: "01.001.001/0001-01"
    - `:receiver_name` [string]: receiver's full name. ex: "Jamie Lannister"
    - `:receiver_tax_id` [string]: receiver's CPF (11 digits formatted or unformatted) or CNPJ (14 digits formatted or unformatted). ex: "012.345.678-90"
    - `:receiver_street_line` [string]: receiver's main address. ex: "Av. Paulista, 200"
    - `:receiver_city` [string]: receiver's address city name. ex: "Sao Paulo"
    - `:receiver_state_code` [string]: receiver's address state code. ex: "SP"
    - `:receiver_zip_code` [string]: receiver's address zip code. ex: "01234-567"

  ## Options:
    - `:data` [list of maps, default nil]: additional info to the br code, example: data: [%{key: "Anticipation discount", value: "3.80"}]
    - `:expiration` [integer, default 86400 (1 day)]: time in seconds counted from the creation datetime until the DynamicBrcode expires. After expiration, the BR code cannot be paid anymore.
    - `:fine` [float, default 2.0]: Percentage charged if the sender pays after the due datetime.
    - `:interest` [float, default 1.0]: Interest percentage charged if the sender pays after the due datetime.
    - `:discounts` [list of maps, default nil]: list of maps with "percentage":float and "due":DateTime or string pairs.
    - `:description` [string, default nil]: additional information to be shown to the sender at the moment of payment.

  ## Return:
    - Dumped JSON string that must be returned to us
  """
  @spec response_due!(
    version: integer,
    created: DateTime.t() | Date.t() | binary,
    due: DateTime.t() | Date.t() | binary,
    key_id: binary,
    status: binary,
    reconciliation_id: binary,
    nominal_amount: integer,
    sender_name: binary,
    sender_tax_id: binary,
    receiver_name: binary,
    receiver_tax_id: binary,
    receiver_street_line: binary,
    receiver_city: binary,
    receiver_state_code: binary,
    receiver_zip_code: binary,
    expiration: integer,
    fine: float,
    interest: float,
    discounts: [map()],
    description: binary,
    data: [map()]
  ) :: any
  def response_due!(options \\ []) do
    options
    |> Check.enforced_keys([
      :version,
      :created,
      :due,
      :key_id,
      :status,
      :reconciliation_id,
      :nominal_amount,
      :sender_name,
      :sender_tax_id,
      :receiver_name,
      :receiver_tax_id,
      :receiver_street_line,
      :receiver_city,
      :receiver_state_code,
      :receiver_zip_code
    ])
    |> Enum.into(%{
      expiration: nil,
      fine: nil,
      interest: nil,
      discounts: nil,
      description: nil,
      data: nil
    })
    |> API.cast_json_to_api_format()
    |> JSON.encode!()
  end

  @doc """
  Helps you respond to an instant DynamicBrcode Read.

  When an instant DynamicBrcode is read by your user, a GET request containing the BR code's UUID will be made
  to your registered URL to retrieve additional information needed to complete the transaction.
  The GET request must be answered in the following format within 5 seconds and with an HTTP status code 200.

  ## Parameters (required):
    - `:version` [integer]: integer that represents how many times the BR code was updated.
    - `:created` [DateTime or string]: creation datetime of the DynamicBrcode. ex: "2022-05-17"
    - `:key_id` [string]: receiver's PixKey id. Can be a tax_id (CPF/CNPJ), a phone number, an email or an alphanumeric sequence (EVP). ex: "+5511989898989"
    - `:status` [string]: BR code status. Options: "created", "overdue", "paid", "canceled" or "expired"
    - `:reconciliation_id` [string]: id to be used for conciliation of the resulting Pix transaction. ex: "cd65c78aeb6543eaaa0170f68bd741ee"
    - `:amount` [integer]: positive integer that represents the amount in cents of the resulting Pix transaction. ex: 1234 (= R$ 12.34)

  ## Parameters (conditionally-required):
    - `:cashier_type` [string, default nil]: cashier's type. Required if the cashAmount is different from 0. Options: "merchant", "participant" and "other"
    - `:cashier_bank_code` [string, default nil]: cashier's bank code. Required if the cashAmount is different from 0. ex: "20018183"

  ## Options:
    - `:data` [list of maps, default nil]: additional info to the br code, example: data: [%{key: "Anticipation discount", value: "3.80"}]
    - `:cash_amount` [integer, default 0]: amount to be withdrawn from the cashier in cents. ex: 1000 (= R$ 10.00)
    - `:expiration` [integer, default 86400 (1 day)]: time in seconds counted from the creation datetime until the DynamicBrcode expires. After expiration, the BR code cannot be paid anymore.
    - `:sender_name` [string, default nil]: sender's full name. ex: "Anthony Edward Stark"
    - `:sender_tax_id` [string, default nil]: sender's CPF (11 digits formatted or unformatted) or CNPJ (14 digits formatted or unformatted). ex: "01.001.001/0001-01"
    - `:amount_type` [string, default "fixed"]: amount type of the Brcode. If the amount type is "custom" the Brcode's amount can be changed by the sender at the moment of payment. Options: "fixed" or "custom"
    - `:description` [string, default nil]: additional information to be shown to the sender at the moment of payment.

  ## Return:
    - Dumped JSON string that must be returned to us
  """
  @spec response_instant!(
    version: integer,
    created: DateTime.t() | Date.t() | binary,
    key_id: binary,
    status: binary,
    reconciliation_id: binary,
    amount: integer,
    expiration: integer,
    sender_name: binary,
    sender_tax_id: binary,
    description: binary,
    amount_type: binary,
    cash_amount: integer,
    cashier_type: binary,
    cashier_bank_code: binary,
    data: [map()]
  ) :: any
  def response_instant!(options \\ []) do
    options
    |> Check.enforced_keys([
      :version,
      :created,
      :key_id,
      :status,
      :reconciliation_id,
      :amount
    ])
    |> Enum.into(%{
      expiration: nil,
      sender_name: nil,
      sender_tax_id: nil,
      description: nil,
      amount_type: nil,
      cash_amount: nil,
      cashier_type: nil,
      cashier_bank_code: nil,
      data: nil
    })
    |> API.cast_json_to_api_format()
    |> JSON.encode!()
  end

  @doc false
  def resource() do
    {
      "DynamicBrcode",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %DynamicBrcode{
      name: json[:name],
      city: json[:city],
      external_id: json[:external_id],
      type: json[:type],
      tags: json[:tags],
      id: json[:id],
      uuid: json[:uuid],
      url: json[:url],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime(),
    }
  end
end
