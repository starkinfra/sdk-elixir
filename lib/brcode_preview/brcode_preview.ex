defmodule StarkInfra.BrcodePreview do
  alias __MODULE__, as: BrcodePreview
  alias StarkInfra.Error
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Organization

  @moduledoc """
  Groups BrcodePreview related functions
  """

  @doc """
  The BrcodePreview object is used to preview information from a BR Code before paying it.

  When you initialize a BrcodePreview, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the objects
  to the Stark Infra API and returns the created object.

  ## Parameters (required):
    - `:id` [binary]: BR Code string for a Pix payment also the information directly encoded in a QR Code. ex: "00020126580014br.gov.bcb.pix0136a629532e-7693-4846-852d-1bbff817b5a8520400005303986540510.005802BR5908T'Challa6009Sao Paulo62090505123456304B14A"
    - `:payer_id` [binary]: Tax id (CPF/CNPJ) of the individual or business requesting the PixKey information. This id is used by the Central Bank to limit request rates. ex: "20.018.183/0001-80"

  ## Parameters (optional):
    - `:end_to_end_id` [binary]: central bank's unique transaction ID. ex: "E79457883202101262140HHX553UPqeq"

  ## Attributes (return-only):
    - `:account_number` [binary]: Payment receiver account number. ex: "1234567"
    - `:account_type` [binary]: Payment receiver account type. ex: "checking"
    - `:amount` [integer]: Value in cents that this payment is expecting to receive. If 0, any value is accepted. ex: 123 (= R$1,23)
    - `:amount_type` [binary]: amount type of the BR Code. If the amount type is "custom" the BR Code's amount can be changed by the sender at the moment of payment. ex: "fixed" or "custom"
    - `:bank_code` [binary]: Payment receiver bank code. ex: "20018183"
    - `:branch_code` [binary]: Payment receiver branch code. ex: "0001"
    - `:cash_amount` [integer]: Amount to be withdrawn from the cashier in cents. ex: 1000 (= R$ 10.00)
    - `:cashier_bank_code` [binary]: Cashier's bank code. ex: "20018183"
    - `:cashier_type` [binary]: Cashier's type. ex: "merchant", "participant" and "other"
    - `:discount_amount` [integer]: Discount value calculated over nominal_amount. ex: 3000
    - `:fine_amount` [integer]: Fine value calculated over nominal_amount. ex: 20000
    - `:interest_amount` [integer]: Interest value calculated over nominal_amount. ex: 10000
    - `:key_id` [binary]: Receiver's PixKey id. ex: "+5511989898989"
    - `:name` [binary]: Payment receiver name. ex: "Tony Stark"
    - `:nominal_amount` [integer]: Brcode emission amount, without fines, fees and discounts. ex: 1234 (= R$ 12.34)
    - `:reconciliation_id` [binary]: Reconciliation ID linked to this payment. If the brcode is dynamic, the reconciliation_id will have from 26 to 35 alphanumeric characters, ex: "cd65c78aeb6543eaaa0170f68bd741ee". If the brcode is static, the reconciliation_id will have up to 25 alphanumeric characters "ah27s53agj6493hjds6836v49"
    - `:reduction_amount` [integer]: Reduction value to discount from nominal_amount. ex: 1000
    - `:scheduled` [DateTime]: date of payment execution. ex: ~U[2020-3-10 10:30:0:0]
    - `:status` [binary]: Payment status. ex: "active", "paid", "canceled" or "unknown"
    - `:tax_id` [binary]: Payment receiver tax ID. ex: "012.345.678-90"
  """
  @enforce_keys [
    :id,
    :payer_id,
  ]
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
    :fine_amount,
    :interest_amount,
    :key_id,
    :name,
    :nominal_amount,
    :reconciliation_id,
    :reduction_amount,
    :scheduled,
    :status,
    :tax_id,
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Process BR Codes before paying them.

  ## Parameters (required):
    - `:previews` [list of BrcodePreview objects]: List of BrcodePreview objects to preview. ex: [StarkInfra.BrcodePreview("00020126580014br.gov.bcb.pix0136a629532e-7693-4846-852d-1bbff817b5a8520400005303986540510.005802BR5908T'Challa6009Sao Paulo62090505123456304B14A")]

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of BrcodePreview objects with updated attributes
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
      fine_amount: json[:fine_amount],
      interest_amount: json[:interest_amount],
      key_id: json[:key_id],
      name: json[:name],
      nominal_amount: json[:nominal_amount],
      reconciliation_id: json[:reconciliation_id],
      reduction_amount: json[:reduction_amount],
      scheduled: json[:scheduled],
      status: json[:status],
      tax_id: json[:tax_id]
    }
  end
end
