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
    - `:scheduled` [Date, DateTime or string]: date of transfer execution. ex: ~D[2020-3-10]
    - `:tax_id` [string]: credit receiver's tax ID (CPF or CNPJ). ex: "20.018.183/0001-80"

  ## Parameters (conditionally required):
  Each `:type` value requires its own subset of these fields: "sac", "price", "american" and "bullet" require nominal_interest and initial_due; "sac" and "price" require exactly one of count or initial_amount (count is also required for "american") plus interval; only "custom" requires invoices, leaving the others unused. For every type, including "custom", exactly one of nominal_amount or amount must also be provided.
    - `:invoices` [list of Invoice structs]: list of Invoice structs to be created and sent to the credit receiver. ex: [%StarkInfra.CreditNote.Invoice{}, %StarkInfra.CreditNote.Invoice{}]
    - `:nominal_amount` [integer]: amount in cents transferred to the credit receiver, before deductions, for every type including "custom". Provide exactly one of nominal_amount or amount; the other value, along with tax_amount and the interest rates, is computed from the invoice schedule. ex: 11234 (= R$ 112.34)
    - `:amount` [integer]: net amount in cents to be disbursed to the credit receiver, for every type including "custom". Provide exactly one of nominal_amount or amount; the other value, along with tax_amount and the interest rates, is computed from the invoice schedule.
    - `:nominal_interest` [float]: yearly nominal interest rate of the credit note, in percentage. ex: 12.5
    - `:initial_due` [Date, DateTime or string]: date of the first invoice. ex: ~D[2020-3-10]
    - `:count` [integer]: quantity of invoices for payment. ex: 12
    - `:initial_amount` [integer]: value of the first invoice in cents. ex: 1234 (= R$ 12.34)
    - `:interval` [string]: interval between invoices. ex: "year", "month"

  ## Parameters (optional):
    - `:rebate_amount` [integer, default nil]: credit analysis fee deducted from lent amount. ex: 11234 (= R$ 112.34)

  Attributes (return-only):
    - `:interest` [float]: yearly effective interest rate of the credit note, in percentage. ex: 12.5
    - `:tax_amount` [integer]: tax amount included in the CreditNote. ex: 100
  """
  @enforce_keys [
    :type
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
