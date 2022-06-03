defmodule StarkInfra.IssuingAuthorization do
  alias __MODULE__, as: IssuingAuthorization
  alias StarkInfra.Error
  alias StarkInfra.Utils.JSON
  alias StarkInfra.Utils.Parse
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization


  @moduledoc """
  Groups IssuingAuthorization related functions
  """

  @doc """
  An IssuingAuthorization presents purchase data to be analysed and answered with an approval or a declination.

  ## Attributes (return-only):
    - `:end_to_end_id` [string]: central bank's unique transaction ID. ex: "E79457883202101262140HHX553UPqeq"
    - `:amount` [integer]: IssuingPurchase value in cents. Minimum = 0. ex: 1234 (= R$ 12.34)
    - `:tax` [integer]: IOF amount taxed for international purchases. ex: 1234 (= R$ 12.34)
    - `:card_id` [string]: unique id returned when IssuingCard is created. ex: "5656565656565656"
    - `:issuer_amount` [integer]: issuer amount. ex: 1234 (= R$ 12.34)
    - `:issuer_currency_code` [string]: issuer currency code. ex: "USD"
    - `:merchant_amount` [integer]: merchant amount. ex: 1234 (= R$ 12.34)
    - `:merchant_currency_code` [string]: merchant currency code. ex: "USD"
    - `:merchant_category_code` [string]: merchant category code. ex: "fastFoodRestaurants"
    - `:merchant_country_code` [string]: merchant country code. ex: "USA"
    - `:acquirer_id` [string]: acquirer ID. ex: "5656565656565656"
    - `:merchant_id` [string]: merchant ID. ex: "5656565656565656"
    - `:merchant_name` [string]: merchant name. ex: "Google Cloud Platform"
    - `:merchant_fee` [integer]: merchant fee charged. ex: 200 (= R$ 2.00)
    - `:wallet_id` [string]: virtual wallet ID. ex: "googlePay"
    - `:method_code` [string]: method code. ex: "chip", "token", "server", "manual", "magstripe" or "contactless"
    - `:score` [float]: internal score calculated for the authenticity of the purchase. Nil in case of insufficient data. ex: 7.6
    - `:is_partial_allowed` [bool]: true if the the merchant allows partial purchases. ex: False
    - `:purpose` [string]: purchase purpose. ex: "purchase"
    - `:card_tags` [list of strings]: tags of the IssuingCard responsible for this purchase. ex: ["travel", "food"]
    - `:holder_tags` [list of strings]: tags of the IssuingHolder responsible for this purchase. ex: ["technology", "john snow"]
  """
  @enforce_keys [
    :id,
    :end_to_end_id,
    :amount,
    :tax,
    :card_id,
    :issuer_amount,
    :issuer_currency_code,
    :merchant_amount,
    :merchant_currency_code,
    :merchant_category_code,
    :merchant_country_code,
    :acquirer_id,
    :merchant_id,
    :merchant_name,
    :merchant_fee,
    :wallet_id,
    :method_code,
    :score,
    :is_partial_allowed,
    :purpose,
    :card_tags,
    :holder_tags
  ]
  defstruct [
    :id,
    :end_to_end_id,
    :amount,
    :tax,
    :card_id,
    :issuer_amount,
    :issuer_currency_code,
    :merchant_amount,
    :merchant_currency_code,
    :merchant_category_code,
    :merchant_country_code,
    :acquirer_id,
    :merchant_id,
    :merchant_name,
    :merchant_fee,
    :wallet_id,
    :method_code,
    :score,
    :is_partial_allowed,
    :purpose,
    :card_tags,
    :holder_tags
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Create a single IssuingAuthorization struct received from IssuingAuthorization at the informed endpoint.
  If the provided digital signature does not check out with the StarkInfra public key, a
  starkinfra.error.InvalidSignatureError will be raised.

  ## Parameters (required):
    - `:content` [string]: response content from request received at user endpoint (not parsed)
    - `:signature` [string]: base-64 digital signature received at response header "Digital-Signature"

  ## Options
    - `cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Parsed IssuingAuthorization struct
  """
  @spec parse(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  )::
    {:ok, IssuingAuthorization.t()} |
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
  Helps you respond IssuingAuthorization requests.

  ## Parameters (required):
    - `:status` [string]: sub-issuer response to the authorization. ex: "accepted" or "denied"

  ## Options
    - `:amount` [integer, default 0]: amount in cents that was authorized. ex: 1234 (= R$ 12.34)
    - `:reason` [string, default ""]: denial reason. ex: "other"
    - `:tags` [list of strings, default []]: tags to filter retrieved object. ex: ["tony", "stark"]

  ## Return:
    - Dumped JSON string that must be returned to us on the IssuingAuthorization request
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

  @doc false
  def resource() do
    {
      "IssuingAuthorization",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingAuthorization{
      id: json[:id],
      end_to_end_id: json[:end_to_end_id],
      amount: json[:amount],
      tax: json[:tax],
      card_id: json[:card_id],
      issuer_amount: json[:issuer_amount],
      issuer_currency_code: json[:issuer_currency_code],
      merchant_amount: json[:merchant_amount],
      merchant_currency_code: json[:merchant_currency_code],
      merchant_category_code: json[:merchant_category_code],
      merchant_country_code: json[:merchant_country_code],
      acquirer_id: json[:acquirer_id],
      merchant_id: json[:merchant_id],
      merchant_name: json[:merchant_name],
      merchant_fee: json[:merchant_fee],
      wallet_id: json[:wallet_id],
      method_code: json[:method_code],
      score: json[:score],
      is_partial_allowed: json[:is_partial_allowed],
      purpose: json[:purpose],
      card_tags: json[:card_tags],
      holder_tags: json[:holder_tags]
    }
  end
end
