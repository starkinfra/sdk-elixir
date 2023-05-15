defmodule StarkInfra.IssuingPurchase do
  alias __MODULE__, as: IssuingPurchase
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.Parse
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
    # IssuingPurchase object
  """

  @doc """
  Displays the IssuingPurchase objects created in your Workspace.

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when IssuingPurchase is created. ex: "5656565656565656"
    - `:holder_name` [binary]: card holder name. ex: "Tony Stark"
    - `:product_id` [binary]: unique card product number (BIN) registered within the card network. ex: "53810200"
    - `:card_id` [binary]: unique id returned when IssuingCard is created. ex: "5656565656565656"
    - `:card_ending` [binary]: last 4 digits of the card number. ex: "1234"
    - `:purpose` [binary]: purchase purpose. ex: "purchase"
    - `:amount` [integer]: IssuingPurchase value in cents. Minimum = 0. ex: 1234 (= R$ 12.34)
    - `:tax` [integer]: IOF amount taxed for international purchases. ex: 1234 (= R$ 12.34)
    - `:issuer_amount` [integer]: issuer amount. ex: 1234 (= R$ 12.34)
    - `:issuer_currency_code` [binary]: issuer currency code. ex: "USD"
    - `:issuer_currency_symbol` [binary]: issuer currency symbol. ex: "$"
    - `:merchant_amount` [integer]: merchant amount. ex: 1234 (= R$ 12.34)
    - `:merchant_currency_code` [binary]: merchant currency code. ex: "USD"
    - `:merchant_currency_symbol` [binary]: merchant currency symbol. ex: "$"
    - `:merchant_category_code` [binary]: merchant category code. ex: "fastFoodRestaurants"
    - `:merchant_country_code` [binary]: merchant country code. ex: "USA"
    - `:acquirer_id` [binary]: acquirer ID. ex: "5656565656565656"
    - `:merchant_id` [binary]: merchant ID. ex: "5656565656565656"
    - `:merchant_name` [binary]: merchant name. ex: "Google Cloud Platform"
    - `:merchant_fee` [integer]: fee charged by the merchant to cover specific costs, such as ATM withdrawal logistics, etc. ex: 200 (= R$ 2.00)
    - `:wallet_id` [binary]: virtual wallet ID. ex: "5656565656565656"
    - `:method_code` [binary]: method code. ex: "chip", "token", "server", "manual", "magstripe" or "contactless"
    - `:score` [float]: internal score calculated for the authenticity of the purchase. nil in case of insufficient data. ex: 7.6
    - `:end_to_end_id` [binary]: Unique id used to identify the transaction through all of its life cycle, even before the purchase is denied or accepted and gets its usual id. ex: "679cd385-642b-49d0-96b7-89491e1249a5"
    - `:tags` [list of binaries]: list of binaries for tagging returned by the sub-issuer during the authorization. ex: ["travel", "food"]
    - `:zip_code` [binary]: zip code of the merchant location. ex: "02101234"

    ## Attributes (IssuingPurchase only):
    - `:issuing_transaction_ids` [binary]: ledger transaction ids linked to this Purchase
    - `:status` [binary]: current IssuingCard status. ex: "approved", "canceled", "denied", "confirmed", "voided"
    - `:updated` [DateTime]: latest update datetime for the IssuingPurchase. ex: ~U[2020-03-10 10:30:0:0]
    - `:created` [DateTime]: creation datetime for the IssuingPurchase. ex: ~U[2020-03-10 10:30:0:0]

    ## Attributes (authorization request only):
    - `:is_partial_allowed` [bool]: true if the merchant allows partial purchases. ex: False
    - `:card_tags` [list of binaries]: tags of the IssuingCard responsible for this purchase. ex: ["travel", "food"]
    - `:holder_tags` [list of binaries]: tags of the IssuingHolder responsible for this purchase. ex: ["technology", "john snow"]
  """
  @enforce_keys [
    :id,
    :holder_name,
    :product_id,
    :card_id,
    :card_ending,
    :purpose,
    :amount,
    :tax,
    :issuer_amount,
    :issuer_currency_code,
    :issuer_currency_symbol,
    :merchant_amount,
    :merchant_currency_code,
    :merchant_currency_symbol,
    :merchant_category_code,
    :merchant_country_code,
    :acquirer_id,
    :merchant_id,
    :merchant_name,
    :merchant_fee,
    :wallet_id,
    :method_code,
    :score,
    :end_to_end_id,
    :tags,
    :zip_code,
    :issuing_transaction_ids,
    :status,
    :updated,
    :created,
    :is_partial_allowed,
    :card_tags,
    :holder_tags,
  ]

  defstruct [
    :id,
    :holder_name,
    :product_id,
    :card_id,
    :card_ending,
    :purpose,
    :amount,
    :tax,
    :issuer_amount,
    :issuer_currency_code,
    :issuer_currency_symbol,
    :merchant_amount,
    :merchant_currency_code,
    :merchant_currency_symbol,
    :merchant_category_code,
    :merchant_country_code,
    :acquirer_id,
    :merchant_id,
    :merchant_name,
    :merchant_fee,
    :wallet_id,
    :method_code,
    :score,
    :end_to_end_id,
    :tags,
    :zip_code,
    :issuing_transaction_ids,
    :status,
    :updated,
    :created,
    :is_partial_allowed,
    :card_tags,
    :holder_tags,
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single IssuingPurchase object previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingPurchase object that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IssuingPurchase.t()} |
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
  Receive a stream of IssuingPurchase objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:end_to_end_ids` [list of binaries, default nil]: central bank's unique transaction ID. ex: "E79457883202101262140HHX553UPqeq"
    - `:holder_ids` [list of binaries, default nil]: card holder IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:card_ids` [list of binaries, default nil]: card  IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["approved", "canceled", "denied", "confirmed", "voided"]
    - `:ids` [list of binaries, default nil]: purchase IDs
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingPurchase objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    end_to_end_ids: [binary],
    holder_ids: [binary],
    card_ids: [binary],
    status: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IssuingPurchase.t()]}} |
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
  @spec page!(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    end_to_end_ids: [binary],
    holder_ids: [binary],
    card_ids: [binary],
    status: [binary],
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
  Receive a list of up to 100 IssuingPurchase objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:end_to_end_ids` [list of binaries, default nil]: central bank's unique transaction ID. ex: "E79457883202101262140HHX553UPqeq"
    - `:holder_ids` [list of binaries, default nil]: card holder IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:card_ids` [list of binaries, default nil]: card  IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["approved", "canceled", "denied", "confirmed", "voided"]
    - `:ids` [list of binaries, default nil]: purchase IDs
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingPurchase objects with updated attributes
    - cursor to retrieve the next page of IssuingPurchase objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    end_to_end_ids: [binary],
    holder_ids: [binary],
    card_ids: [binary],
    status: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IssuingPurchase.t()]}} |
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
    end_to_end_ids: [binary],
    holder_ids: [binary],
    card_ids: [binary],
    status: [binary],
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
  Create a single verified IssuingPurchase authorization request from a content string
  Use this method to parse and verify the authenticity of the authorization request received at the informed endpoint.
  Authorization requests are posted to your registered endpoint whenever IssuingPurchases are received.
  They present IssuingPurchase data that must be analyzed and answered with approval or declination.
  If the provided digital signature does not check out with the StarkInfra public key, a stark.exception.InvalidSignatureException will be raised.
  If the authorization request is not answered within 2 seconds or is not answered with an HTTP status code 200 the IssuingPurchase will go through the pre-configured stand-in validation.

  ## Parameters (required):
    - `:content` [binary]: response content from request received at user endpoint (not parsed)
    - `:signature` [binary]: base-64 digital signature received at response header "Digital-Signature"

  ## Parameters (optional):
    - `cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Parsed IssuingPurchase object
  """
  @spec parse(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  )::
    {:ok, IssuingPurchase.t()} |
    {:error, [error: Error.t()]}
  def parse(options) do
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
      resource_maker: &resource_maker/1,
      user: user
    )
  end

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
    Parse.parse_and_verify!(
      content: content,
      signature: signature,
      cache_pid: cache_pid,
      key: nil,
      resource_maker: &resource_maker/1,
      user: user
    )
  end

  @doc """
  Helps you respond to a IssuingPurchase authorization

  ## Parameters (required):
    - `:status` [binary]: sub-issuer response to the authorization. ex: "approved" or "denied"

  ## Parameters (conditionally-required):
    - `:reason` [binary, default nil]: denial reason. Options: "other", "blocked", "lostCard", "stolenCard", "invalidPin", "invalidCard", "cardExpired", "issuerError", "concurrency", "standInDenial", "subIssuerError", "invalidPurpose", "invalidZipCode", "invalidWalletId", "inconsistentCard", "settlementFailed", "cardRuleMismatch", "invalidExpiration", "prepaidInstallment", "holderRuleMismatch", "insufficientBalance", "tooManyTransactions", "invalidSecurityCode", "invalidPaymentMethod", "confirmationDeadline", "withdrawalAmountLimit", "insufficientCardLimit", "insufficientHolderLimit"

  ## Parameters (optional):
    - `:amount` [binary, default nil]: amount in cents that was authorized. ex: 1234 (= R$ 12.34)
    - `:tags` [list of binaries, default nil]: tags to filter retrieved object. ex: ["tony", "stark"]

    ## Return:
    - Dumped JSON binary that must be returned to us
  """

  @spec response(
    map(),
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, IssuingPurchase.t()} |
    {:error, [Error.t()]}
  def response(status, reason\\nil, amount\\nil, tags\\nil) do
    body = %{status: status, reason: reason, amount: amount, tags: tags}
    params = %{authorization: body}
    params
    |> Jason.encode!
  end

  @spec resource ::
          {<<_::120>>, (nil | maybe_improper_list | map -> StarkInfra.IssuingPurchase.t())}
  @doc false
  def resource() do
    {
      "IssuingPurchase",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingPurchase{
      id: json[:id],
      holder_name: json[:holder_name],
      product_id: json[:product_id],
      card_id: json[:card_id],
      card_ending: json[:card_ending],
      amount: json[:amount],
      purpose: json[:purpose],
      tax: json[:tax],
      issuer_amount: json[:issuer_amount],
      issuer_currency_code: json[:issuer_currency_code],
      issuer_currency_symbol: json[:issuer_currency_symbol],
      merchant_amount: json[:merchant_amount],
      merchant_currency_code: json[:merchant_currency_code],
      merchant_currency_symbol: json[:merchant_currency_symbol],
      merchant_category_code: json[:merchant_category_code],
      merchant_country_code: json[:merchant_country_code],
      acquirer_id: json[:acquirer_id],
      merchant_id: json[:merchant_id],
      merchant_name: json[:merchant_name],
      merchant_fee: json[:merchant_fee],
      wallet_id: json[:wallet_id],
      method_code: json[:method_code],
      score: json[:score],
      end_to_end_id: json[:end_to_end_id],
      tags: json[:tags],
      zip_code: json[:zip_code],
      issuing_transaction_ids: json[:issuing_transaction_ids],
      status: json[:status],
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime(),
      is_partial_allowed: json[:is_partial_allowed],
      card_tags: json[:card_tags],
      holder_tags: json[:holder_tags],
    }
  end
end
