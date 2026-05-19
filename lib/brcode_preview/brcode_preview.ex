defmodule StarkInfra.BrcodePreview do
  alias __MODULE__, as: BrcodePreview
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.API
  alias StarkInfra.BrcodePreview.Subscription
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups BrcodePreview related functions
  """

  @doc """
  The BrcodePreview struct provides information about a BR Code from a Pix payment
  before paying it. When you initialize a BrcodePreview, the BR Code is not
  automatically parsed by the Stark Infra API. The 'create' function sends the
  structs to the Stark Infra API and returns the list of previewed structs.

  ## Parameters (required):
    - `:id` [string]: BR Code string from a Pix payment. Same payload encoded inside a QR Code. ex: "00020126580014br.gov.bcb.pix0136a629532e-7693-4846-852d-1bbff817b5a8520400005303986540510.005802BR5908T'Challa6009Sao Paulo62090505123456304B14A"
    - `:payer_id` [string]: tax id (CPF/CNPJ) of the individual or business requesting the BR Code information. Used by the Central Bank to rate-limit consultations. ex: "20.018.183/0001-80"

  ## Parameters (optional):
    - `:end_to_end_id` [string, default nil]: central bank's unique transaction id. ex: "E79457883202101262140HHX553UPqeq"

  ## Attributes (return-only):
    - `:account_number` [string]: payment receiver account number. ex: "1234567"
    - `:account_type` [string]: payment receiver account type. ex: "checking", "savings", "salary" or "payment"
    - `:amount` [integer]: amount in cents this BR Code is expecting to receive. 0 means any value is accepted. ex: 123 (= R$ 1.23)
    - `:amount_type` [string]: whether the BR Code's amount is fixed or freely chosen at payment time. ex: "fixed" or "custom"
    - `:bank_code` [string]: payment receiver bank code. ex: "20018183"
    - `:branch_code` [string]: payment receiver branch code. ex: "0001"
    - `:cash_amount` [integer]: amount in cents to be withdrawn at the cashier (Pix Saque / Pix Troco). ex: 1000 (= R$ 10.00)
    - `:cashier_bank_code` [string]: cashier's bank code. ex: "20018183"
    - `:cashier_type` [string]: cashier's type. ex: "merchant", "participant" or "other"
    - `:discount_amount` [integer]: discount value calculated over nominal_amount. ex: 3000
    - `:due` [DateTime]: BR Code due date. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:fine_amount` [integer]: fine value calculated over nominal_amount. ex: 20000
    - `:interest_amount` [integer]: interest value calculated over nominal_amount. ex: 10000
    - `:key_id` [string]: receiver's Pix key id. ex: "+5511989898989"
    - `:name` [string]: payment receiver name. ex: "Tony Stark"
    - `:nominal_amount` [integer]: BR Code emission amount, before fines, fees and discounts. ex: 1234 (= R$ 12.34)
    - `:reconciliation_id` [string]: reconciliation id linked to this payment. Dynamic BR Codes carry 26-35 alphanumeric chars; static BR Codes carry up to 25. ex: "cd65c78aeb6543eaaa0170f68bd741ee"
    - `:reduction_amount` [integer]: reduction value to discount from nominal_amount. ex: 1000
    - `:scheduled` [DateTime]: scheduled execution datetime of the payment. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:status` [string]: BR Code lifecycle state. ex: "active", "paid", "canceled" or "unknown"
    - `:subscription` [BrcodePreview.Subscription]: embedded subscription snapshot when the BR Code carries Pix-recurring-debit metadata. nil for non-subscription BR Codes.
    - `:tax_id` [string]: payment receiver tax id. ex: "012.345.678-90"
  """
  @enforce_keys [:id, :payer_id]
  defstruct [
    :id,
    :payer_id,
    :end_to_end_id,
    :account_number,
    :account_type,
    :amount,
    :amount_type,
    :bank_code,
    :branch_code,
    :cash_amount,
    :cashier_bank_code,
    :cashier_type,
    :discount_amount,
    :due,
    :fine_amount,
    :interest_amount,
    :key_id,
    :name,
    :nominal_amount,
    :reconciliation_id,
    :reduction_amount,
    :scheduled,
    :status,
    :subscription,
    :tax_id
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of BrcodePreview structs for creation in the Stark Infra API

  ## Parameters (required):
    - `:previews` [list of BrcodePreview structs]: list of BrcodePreview structs to be previewed in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of BrcodePreview structs with updated attributes
  """
  @spec create(
    [BrcodePreview.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [BrcodePreview.t()]} |
    {:error, [Error.t()]}
  def create(previews, options \\ []) do
    Rest.post(
      resource(),
      previews,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    [BrcodePreview.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(previews, options \\ []) do
    Rest.post!(
      resource(),
      previews,
      options
    )
  end

  defp parse_subscription(nil), do: nil
  defp parse_subscription(value) when value == %{}, do: nil
  defp parse_subscription(value), do: API.from_api_json(value, &Subscription.resource_maker/1)

  @doc false
  def resource() do
    {
      "BrcodePreview",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %BrcodePreview{
      id: json[:id],
      payer_id: json[:payer_id],
      end_to_end_id: json[:end_to_end_id],
      account_number: json[:account_number],
      account_type: json[:account_type],
      amount: json[:amount],
      amount_type: json[:amount_type],
      bank_code: json[:bank_code],
      branch_code: json[:branch_code],
      cash_amount: json[:cash_amount],
      cashier_bank_code: json[:cashier_bank_code],
      cashier_type: json[:cashier_type],
      discount_amount: json[:discount_amount],
      due: json[:due] |> Check.datetime(),
      fine_amount: json[:fine_amount],
      interest_amount: json[:interest_amount],
      key_id: json[:key_id],
      name: json[:name],
      nominal_amount: json[:nominal_amount],
      reconciliation_id: json[:reconciliation_id],
      reduction_amount: json[:reduction_amount],
      scheduled: json[:scheduled] |> Check.datetime(),
      status: json[:status],
      subscription: parse_subscription(json[:subscription]),
      tax_id: json[:tax_id]
    }
  end
end
