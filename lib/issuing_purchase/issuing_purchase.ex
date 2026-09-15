defmodule StarkInfra.IssuingPurchase do
  alias __MODULE__, as: IssuingPurchase
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.JSON
  alias StarkInfra.Utils.Parse
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
    # IssuingPurchase struct
  """

  @doc """
  Displays the IssuingPurchase structs created in your Workspace.

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when IssuingPurchase is created. ex: "5656565656565656"
    - `:holder_name` [string]: card holder name. ex: "Tony Stark"
    - `:card_id` [string]: unique id returned when IssuingCard is created. ex: "5656565656565656"
    - `:card_ending` [string]: last 4 digits of the card number. ex: "1234"
    - `:amount` [integer]: IssuingPurchase value in cents. Minimum = 0. ex: 1234 (= R$ 12.34)
    - `:tax` [integer]: IOF amount taxed for international purchases. ex: 1234 (= R$ 12.34)
    - `:issuer_amount` [integer]: issuer amount. ex: 1234 (= R$ 12.34)
    - `:issuer_currency_code` [string]: issuer currency code. ex: "USD"
    - `:issuer_currency_symbol` [string]: issuer currency symbol. ex: "$"
    - `:merchant_amount` [integer]: merchant amount. ex: 1234 (= R$ 12.34)
    - `:merchant_currency_code` [string]: merchant currency code. ex: "USD"
    - `:merchant_currency_symbol` [string]: merchant currency symbol. ex: "$"
    - `:merchant_category_code` [string]: merchant category code. ex: "fastFoodRestaurants"
    - `:merchant_country_code` [string]: merchant country code. ex: "USA"
    - `:acquirer_id` [string]: acquirer ID. ex: "5656565656565656"
    - `:merchant_id` [string]: merchant ID. ex: "5656565656565656"
    - `:merchant_name` [string]: merchant name. ex: "Google Cloud Platform"
    - `:merchant_fee` [integer]: fee charged by the merchant to cover specific costs, such as ATM withdrawal logistics, etc. ex: 200 (= R$ 2.00)
    - `:wallet_id` [string]: virtual wallet ID. ex: "5656565656565656"
    - `:method_code` [string]: method code. ex: "chip", "token", "server", "manual", "magstripe" or "contactless"
    - `:score` [float]: internal score calculated for the authenticity of the purchase. nil in case of insufficient data. ex: 7.6
    - `:issuing_transaction_ids` [string]: ledger transaction ids linked to this Purchase
    - `:end_to_end_id` [string]: central bank's unique transaction ID. ex: "E79457883202101262140HHX553UPqeq"
    - `:status` [string]: current IssuingCard status. ex: "approved", "canceled", "denied", "confirmed", "voided"
    - `:tags` [string]: list of strings for tagging returned by the sub-issuer during the authorization. ex: ["travel", "food"]
    - `:updated` [DateTime]: latest update DateTime for the IssuingPurchase. ex: ~U[2020-3-10 10:30:0:0]
    - `:created` [DateTime]: creation datetime for the IssuingPurchase. ex: ~U[2020-03-10 10:30:0:0]

  ## Attributes (authorization request only):
    - `:purpose` [string]: purchase purpose. ex: "purchase"
    - `:is_partial_allowed` [bool]: true if the merchant allows partial purchases. ex: false
    - `:card_tags` [list of strings]: tags of the IssuingCard responsible for this purchase. ex: ["travel", "food"]
    - `:holder_id` [string]: card holder ID. ex: "5656565656565656"
    - `:holder_tags` [list of strings]: tags of the IssuingHolder responsible for this purchase. ex: ["technology", "john snow"]
  """
  @enforce_keys [
    :id,
    :holder_name,
    :card_id,
    :card_ending,
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
    :issuing_transaction_ids,
    :end_to_end_id,
    :status,
    :tags,
    :updated,
    :created,
    :purpose,
    :is_partial_allowed,
    :card_tags,
    :holder_id,
    :holder_tags
  ]

  defstruct [
    :id,
    :holder_name,
    :card_id,
    :card_ending,
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
    :issuing_transaction_ids,
    :end_to_end_id,
    :status,
    :tags,
    :updated,
    :created,
    :purpose,
    :is_partial_allowed,
    :card_tags,
    :holder_id,
    :holder_tags
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single IssuingPurchase struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingPurchase struct with updated attributes
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
  Receive a stream of IssuingPurchases structs previously created in the Stark Infra API

  ## Options:
    - `:ids` [list of strings, default [], default nil]: purchase IDs
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:end_to_end_ids` [list of strings, default []]: central bank's unique transaction ID. ex: "E79457883202101262140HHX553UPqeq"
    - `:holder_ids` [list of strings, default []]: card holder IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:card_ids` [list of strings, default []]: card  IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["approved", "canceled", "denied", "confirmed", "voided"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingPurchase structs with updated attributes
  """
  @spec query(
    ids: [binary],
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    end_to_end_ids: [binary],
    holder_ids: [binary],
    card_ids: [binary],
    status: [binary],
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
    ids: [binary],
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    end_to_end_ids: [binary],
    holder_ids: [binary],
    card_ids: [binary],
    status: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of IssuingPurchase structs previously created in the Stark Infra API and the cursor to the next page.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:ids` [list of strings, default [], default nil]: purchase IDs
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:end_to_end_ids` [list of strings, default []]: central bank's unique transaction ID. ex: "E79457883202101262140HHX553UPqeq"
    - `:holder_ids` [list of strings, default []]: card holder IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:card_ids` [list of strings, default []]: card  IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["approved", "canceled", "denied", "confirmed", "voided"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingPurchase structs with updated attributes
    - cursor to retrieve the next page of IssuingPurchase structs
  """
  @spec page(
    cursor: binary,
    ids: [binary],
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    end_to_end_ids: [binary],
    holder_ids: [binary],
    card_ids: [binary],
    status: [binary],
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
    ids: [binary],
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    end_to_end_ids: [binary],
    holder_ids: [binary],
    card_ids: [binary],
    status: [binary],
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
      "IssuingPurchase",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingPurchase{
      id: json[:id],
      holder_name: json[:holder_name],
      card_id: json[:card_id],
      card_ending: json[:card_ending],
      amount: json[:amount],
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
      issuing_transaction_ids: json[:issuing_transaction_ids],
      end_to_end_id: json[:end_to_end_id],
      status: json[:status],
      tags: json[:tags],
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime(),
      purpose: json[:purpose],
      is_partial_allowed: json[:is_partial_allowed],
      card_tags: json[:card_tags],
      holder_id: json[:holder_id],
      holder_tags: json[:holder_tags]
    }
  end

  @doc """
  Create a single IssuingPurchase struct received from IssuingPurchase at the informed endpoint.
  If the provided digital signature does not check out with the StarkInfra public key, a
  starkinfra.error.InvalidSignatureError will be raised.

  ## Parameters (required):
    - `:content` [string]: response content from request received at user endpoint (not parsed)
    - `:signature` [string]: base-64 digital signature received at response header "Digital-Signature"

  ## Options
    - `cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Parsed IssuingPurchase struct
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
  Helps you respond IssuingPurchase authorization requests.

  ## Parameters (required):
    - `:status` [string]: sub-issuer response to the authorization. ex: "accepted" or "denied"

  ## Options
    - `:amount` [integer, default 0]: amount in cents that was authorized. ex: 1234 (= R$ 12.34)
    - `:reason` [string, default ""]: denial reason. ex: "other"
    - `:tags` [list of strings, default []]: tags to filter retrieved object. ex: ["tony", "stark"]

  ## Return:
    - Dumped JSON string that must be returned to us on the IssuingPurchase authorization request
  """
  @spec response!(
    status: binary,
    amount: integer,
    reason: binary,
    tags: [binary]
  ) :: any
  def response!(status, options \\ []) do
    options = options ++ [status: status]
    JSON.encode!(%{authorization:
      Enum.into(options |> Check.enforced_keys([:status]), %{amount: 0, reason: "", tags: []})
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
    })
  end
end
