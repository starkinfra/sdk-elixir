defmodule StarkInfra.CreditPreview.CreditNotePreview do
  alias __MODULE__, as: CreditNotePreview
  alias StarkInfra.Utils.API
  alias StarkInfra.CreditNote.Invoice

  @moduledoc """
  Groups CreditNotePreview related functions
  """

  @doc """
  A CreditNotePreview is used to preview a CCB contract between the borrower and lender with a specific table type.
  When you initialize a CreditNotePreview, the entity will be automatically sent to the Stark Infra API.
  The 'create' function of the parent CreditPreview struct sends the structs to the Stark Infra API and
  returns the list of preview data.

  ## Parameters (required):
    - `:type` [string]: table type that defines the amortization system. Options: "sac", "price", "american", "bullet", "custom"
    - `:nominal_amount` [integer]: amount in cents transferred to the credit receiver, before deductions, for every type including "custom". Provide exactly one of nominal_amount or amount; the other value, along with tax_amount and the interest rates, is computed from the invoice schedule. ex: 11234 (= R$ 112.34)
    - `:scheduled` [Date, DateTime or string]: date of transfer execution. ex: ~D[2020-3-10]
    - `:tax_id` [string]: credit receiver's tax ID (CPF or CNPJ). ex: "20.018.183/0001-80"

  ## Parameters (conditionally required):
    - `:invoices` [list of Invoice structs, default nil]: list of Invoice structs to be created and sent to the credit receiver. Required only when `:type` is "custom". ex: [%StarkInfra.CreditNote.Invoice{}, %StarkInfra.CreditNote.Invoice{}]
    - `:nominal_interest` [float, default nil]: yearly nominal interest rate of the credit note, in percentage. Required for "sac", "price", "american" and "bullet". ex: 12.5
    - `:initial_due` [Date, DateTime or string, default nil]: date of the first invoice. Required for "sac", "price", "american" and "bullet". ex: ~D[2020-3-10]
    - `:count` [integer, default nil]: quantity of invoices for payment. Required for "sac", "price" and "american". ex: 12
    - `:initial_amount` [integer, default nil]: value of the first invoice in cents. Required for "sac" or "price" when `:count` is not informed. ex: 1234 (= R$ 12.34)
    - `:interval` [string, default nil]: interval between invoices. Required for "sac" and "price". ex: "year", "month"
    - `:amount` [integer, default nil]: net amount in cents to be disbursed to the credit receiver, for every type including "custom". Provide exactly one of nominal_amount or amount.

  ## Parameters (optional):
    - `:rebate_amount` [integer, default nil]: credit analysis fee deducted from lent amount. ex: 11234 (= R$ 112.34)

  Attributes (return-only):
    - `:interest` [float, default nil]: yearly effective interest rate of the credit note, in percentage. ex: 12.5
    - `:tax_amount` [integer, default nil]: tax amount included in the CreditNote. ex: 100
  """
  @enforce_keys [
    :type,
    :nominal_amount,
    :scheduled,
    :tax_id
  ]
  defstruct [
    :type,
    :nominal_amount,
    :scheduled,
    :tax_id,
    :invoices,
    :nominal_interest,
    :initial_due,
    :count,
    :initial_amount,
    :interval,
    :rebate_amount,
    :amount,
    :interest,
    :tax_amount
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def resource_maker(json) do
    %CreditNotePreview{
      type: json[:type],
      nominal_amount: json[:nominal_amount],
      scheduled: json[:scheduled],
      tax_id: json[:tax_id],
      invoices: json[:invoices] && json[:invoices] |> Enum.map(fn invoice -> API.from_api_json(invoice, &Invoice.resource_maker/1) end),
      nominal_interest: json[:nominal_interest],
      initial_due: json[:initial_due],
      count: json[:count],
      initial_amount: json[:initial_amount],
      interval: json[:interval],
      rebate_amount: json[:rebate_amount],
      amount: json[:amount],
      interest: json[:interest],
      tax_amount: json[:tax_amount]
    }
  end
end
