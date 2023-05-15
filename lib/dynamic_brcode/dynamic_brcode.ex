defmodule StarkInfra.DynamicBrcode do
  alias __MODULE__, as: DynamicBrcode
  alias StarkInfra.Error
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Parse
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization

  @moduledoc """
  Groups DynamicBrcode related functions
  """

  @doc """
  BR Codes store information represented by Pix QR Codes, which are used to
  send or receive Pix transactions in a convenient way.
  DynamicBrcodes represent charges with information that can change at any time,
  since all data needed for the payment is requested dynamically to an URL stored
  in the BR Code. Stark Infra will receive the GET request and forward it to your
  registered endpoint with a GET request containing the UUID of the BR Code for
  identification.

  When you initialize a DynamicBrcode, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the objects
  to the Stark Infra API and returns the created object.

  ## Parameters (required):
    - `:name` [binary]: receiver's name. ex: "Tony Stark"
    - `:city` [binary]: receiver's city name. ex: "Rio de Janeiro"
    - `:external_id` [binary]: binary that must be unique among all your DynamicBrcodes. Duplicated external ids will cause failures. ex: "my-internal-id-123456"

  ## Parameters (optional):
    - `:type` [binary, default "instant"]: type of the DynamicBrcode. ex: "instant", "due"
    - `:tags` [list of binaries, default []]: list of binaries for tagging. ex: ["travel", "food"]

  ## Attributes (return-only):
    - `:id` [binary]: id returned on creation, this is the BR Code. ex: "00020126360014br.gov.bcb.pix0114+552840092118152040000530398654040.095802BR5915Jamie Lannister6009Sao Paulo620705038566304FC6C"
    - `:uuid` [binary]: unique uuid returned when the DynamicBrcode is created. ex: "4e2eab725ddd495f9c98ffd97440702d"
    - `:url` [binary]: url link to the BR Code image. ex: "https://brcode-h.development.starkinfra.com/dynamic-qrcode/901e71f2447c43c886f58366a5432c4b.png"
    - `:created` [DateTime]: creation DateTime for the CreditNote. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update DateTime for the CreditNote. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :name,
    :city,
    :external_id,
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
  Send a list of DynamicBrcode objects for creation at the Stark Infra API

  ## Parameters (required):
    - `:brcodes` [list of DynamicBrcode objects]: list of DynamicBrcode objects to be created in the API.

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of DynamicBrcode objects with updated attributes
  """
  @spec create(
    [DynamicBrcode.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [DynamicBrcode.t()]} |
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
    [DynamicBrcode.t() | map()],
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
  Receive a single DynamicBrcode object previously created in the Stark Infra API by its uuid

  ## Parameters (required):
    - `:uuid` [binary]: object's unique uuid. ex: "901e71f2447c43c886f58366a5432c4b"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - DynamicBrcode object with updated attributes
  """
  @spec get(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [DynamicBrcode.t()]} |
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
  Receive a stream of DynamicBrcode objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020, 3, 10]
    - `:external_ids` [list of binaries, default nil]: list of external_ids to filter retrieved objects. ex: ["my_external_id1", "my_external_id2"]
    - `:uuids` [list of binaries, default nil]: list of uuids to filter retrieved objects. ex: ["901e71f2447c43c886f58366a5432c4b", "4e2eab725ddd495f9c98ffd97440702d"]
    - `:tags` [list of binaries, default nil]: list of tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of DynamicBrcode objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    external_ids: [binary],
    tags: [binary],
    uuids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, {:ok, [DynamicBrcode.t()]}} |
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
    external_ids: [binary],
    tags: [binary],
    uuids: [binary],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 DynamicBrcode objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020, 3, 10]
    - `:external_ids` [list of binaries, default nil]: list of external_ids to filter retrieved objects. ex: ["my_external_id1", "my_external_id2"]
    - `:uuids` [list of binaries, default nil]: list of uuids to filter retrieved objects. ex: ["901e71f2447c43c886f58366a5432c4b", "4e2eab725ddd495f9c98ffd97440702d"]
    - `:tags` [list of binaries, default nil]: list of tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
    - list of DynamicBrcode objects with updated attributes
    - cursor to retrieve the next page of DynamicBrcode objects
  """
  @spec page(
    cursor: binary | nil,
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    external_ids: [binary] | nil,
    tags: [binary] | nil,
    uuids: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [DynamicBrcode.t()]}} |
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
    external_ids: [binary],
    tags: [binary],
    uuids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    [DynamicBrcode.t()]
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Helps you respond to a due DynamicBrcode Read

  When a Due DynamicBrcode is read by your user, a GET request containing the BR Code's
  UUID will be made to your registered URL to retrieve additional information needed
  to complete the transaction.
  The GET request must be answered in the following format, within 5 seconds, and with
  an HTTP status code 200.

  ## Parameters (required):
    - `:version` [integer]: integer that represents how many times the BR Code was updated.
    - `:created` [DateTime or binary] creation datetime in ISO format of the DynamicBrcode. ex: ~U[2020-3-10 10:30:0:0]
    - `:due` [DateTime or binary]: requested payment due datetime in ISO format. ex: ~U[2020-3-10 10:30:0:0]
    - `:key_id` [binary]: receiver's PixKey id. Can be a tax_id (CPF/CNPJ), a phone number, an email or an alphanumeric sequence (EVP). ex: "+5511989898989"
    - `:status` [binary]: BR Code status. ex: "created", "overdue", "paid", "canceled" or "expired"
    - `:reconciliation_id` [binary]: id to be used for conciliation of the resulting Pix transaction. This id must have from to 26 to 35 alphanumeric characters ex: "cd65c78aeb6543eaaa0170f68bd741ee"
    - `:nominal_amount` [integer]: positive integer that represents the amount in cents of the resulting Pix transaction. ex: 1234 (= R$ 12.34)
    - `:sender_name` [binary]: sender's full name. ex: "Anthony Edward Stark"
    - `:receiver_name` [binary]: receiver's full name. ex: "Jamie Lannister"
    - `:receiver_street_line` [binary]: receiver's main address. ex: "Av. Paulista, 200"
    - `:receiver_city` [binary]: receiver's address city name. ex: "Sao Paulo"
    - `:receiver_state_code` [binary]: receiver's address state code. ex: "SP"
    - `:receiver_zip_code` [binary]: receiver's address zip code. ex: "01234-567"

    ## Parameters (optional):
    - `:expiration [integer, default 86400 (1 day)]: time in seconds counted from the creation datetime until the DynamicBrcode expires. After expiration, the BR Code cannot be paid anymore.
    - `:sender_tax_id`: [binary, default nil]: sender's CPF (11 digits formatted or unformatted) or CNPJ (14 digits formatted or unformatted). ex: "01.001.001/0001-01"
    - `:receiver_tax_id`: [binary, default nil]: receiver's CPF (11 digits formatted or unformatted) or CNPJ (14 digits formatted or unformatted). ex: "012.345.678-90"
    - `:fine [float:, default 2.0]: Percentage charged if the sender pays after the due datetime.
    - `:interest`: [float, default 1.0]: Interest percentage charged if the sender pays after the due datetime.
    - `:discounts`: [list of dictionaries, default nil]: list of dictionaries with "percentage":float and "due":DateTime or binary pairs.
    - `:description`: [binary, default nil]: additional information to be shown to the sender at the moment of payment.

  ## Return:
    - Dumped JSON binary that must be returned to us
  """

  @spec response_due(
    map()
  ) ::
    {:ok, DynamicBrcode.t()} |
    {:error, [Error.t()]}
  def response_due(body) do
    params = %{
      version: body.version,
      created: body.created,
      due: body.due,
      keyId: body.key_id,
      status: body.status,
      reconciliationId: body.reconciliation_id,
      nominalAmount: body.nominal_amount,
      sendeNname: body.sender_name,
      senderTaxId: body.sender_tax_id,
      receiverName: body.receiver_name,
      receiverStreetLine: body.receiver_street_line,
      receiverCity: body.receiver_city,
      receiverStateCode: body.receiver_state_code,
      expiration: body.expiration,
      receiverTaxId: body.receiver_tax_id,
      fine: body.fine,
      interest: body.interest,
      discounts: body.discounts,
      description: body.description,
    }
    params
    |> Jason.encode!
  end

  @doc """
  Helps you respond to an instant DynamicBrcode Read

  When an instant DynamicBrcode is read by your user, a GET request containing the BR Code's UUID will be made
  to your registered URL to retrieve additional information needed to complete the transaction.
  The GET request must be answered in the following format within 5 seconds and with an HTTP status code 200.

  ## Parameters (required):
    - `:version` [integer]: integer that represents how many times the BR Code was updated.
    - `:created` [DateTime or binary]: creation datetime of the DynamicBrcode. ex: "2022-05-17"
    - `:key_id` [binary]: receiver's PixKey id. Can be a tax_id (CPF/CNPJ), a phone number, an email or an alphanumeric sequence (EVP). ex: "+5511989898989"
    - `:status` [binary]: BR Code status. ex: "created", "overdue", "paid", "canceled" or "expired"
    - `:reconciliation_id` [binary]: id to be used for conciliation of the resulting Pix transaction. ex: "cd65c78aeb6543eaaa0170f68bd741ee"
    - `:amount` [integer]: positive integer that represents the amount in cents of the resulting Pix transaction. ex: 1234 (= R$ 12.34)

  ## Parameters (conditionally-required):
    - `:cashier_type` [binary, default nil]: cashier's type. Required if the cash_amount is different from 0. ex: "merchant", "participant" and "other"
    - `:cashier_bank_code` [binary, default nil]: cashier's bank code. Required if the cash_amount is different from 0. ex: "20018183"

  ## Parameters (optional):
    - `:cash_amount` [integer, default 0]: amount to be withdrawn from the cashier in cents. ex: 1000 (= R$ 10.00)
    - `:expiration` [integer, default 86400 (1 day)]: time in seconds counted from the creation datetime until the DynamicBrcode expires. After expiration, the BR Code cannot be paid anymore. Default value: 86400 (1 day)
    - `:sender_name` [binary, default nil]: sender's full name. ex: "Anthony Edward Stark"
    - `:sender_tax_id` [binary, default nil]: sender's CPF (11 digits formatted or unformatted) or CNPJ (14 digits formatted or unformatted). ex: "01.001.001/0001-01"
    - `:amount_type` [binary, default "fixed"]: amount type of the Brcode. If the amount type is "custom" the Brcode's amount can be changed by the sender at the moment of payment. Options: "fixed"or "custom"
    - `:description` [binary, default nil]: additional information to be shown to the sender at the moment of payment.
  ## Return:
    - Dumped JSON string that must be returned to us
  """
  @spec response_instant(
    map()
  ) ::
    {:ok, DynamicBrcode.t()} |
    {:error, [Error.t()]}
  def response_instant(body \\ nil) do
    params = %{
      version: body.version,
      created: body.created,
      keyId: body.key_id,
      status: body.status,
      reconciliationId: body.reconciliation_id,
      amount: body.amount,
      cashierType: body.cashier_type,
      cashierBankCode: body.cashier_bank_code,
      cashAmount: body.cash_amount,
      expiration: body.expiration ,
      senderName: body.sender_name,
      senderTaxId: body.sender_tax_id,
      amountType: body.amount_type,
      description: body.description
    }
    params
    |> Jason.encode!
  end

  @doc """
  Verify a DynamicBrcode Read

  When a DynamicBrcode is read by your user, a GET request will be made to your registered URL to
  retrieve additional information needed to complete the transaction.
  Use this method to verify the authenticity of a GET request received at your registered endpoint.
  If the provided digital signature does not check out with the StarkInfra public key,
  a StarkInfra.Exception.InvalidSignatureException will be raised.

  ## Parameters (required):
    - `:uuid` [binary]: unique uuid of the DynamicBrcode, passed as a path variable in the DynamicBrcode Read request. ex: "4e2eab725ddd495f9c98ffd97440702d"
    - `:signature` [binary]: base-64 digital signature received at response header "Digital-Signature"

  ## Options
    - `cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - verified BR Code's uuid.
  """
  @spec verify(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  )::
    {:ok, DynamicBrcode.t()} |
    {:error, [error: Error.t()]}
  def verify(options) do
    %{content: uuid, signature: signature, cache_pid: cache_pid, user: user} =
      Enum.into(
        options |> Check.enforced_keys([:content, :signature]),
        %{cache_pid: nil, user: nil}
      )
    Parse.parse_and_verify!(
      content: uuid,
      signature: signature,
      cache_pid: cache_pid,
      key: nil,
      resource_maker: &resource_maker/1,
      user: user
    )
  end

  @doc """
  Same as verify(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec verify!(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  ) :: any
  def verify!(options \\ []) do
    %{content: uuid, signature: signature, cache_pid: cache_pid, user: user} =
      Enum.into(
        options |> Check.enforced_keys([:content, :signature]),
        %{cache_pid: nil, user: nil}
      )
    Parse.parse_and_verify!(
      content: uuid,
      signature: signature,
      cache_pid: cache_pid,
      key: nil,
      resource_maker: &resource_maker/1,
      user: user
    )
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
      created: json[:created],
      updated: json[:updated]
    }
  end
end
