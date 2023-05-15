defmodule StarkInfra.CreditNotePreview do
  alias __MODULE__, as: CreditNotePreview

  @moduledoc """
  Groups CreditNotePreview related functions
  """

  @doc """
  A CreditNotePreview is used to preview a CCB contract between the borrower and lender with a specific table type.

  When you initialize a CreditNotePreview, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the objects
  to the Stark Infra API and returns the created object.

  ## Parameters (required):
    - `:type` [binary]: table type that defines the amortization system. ex: "sac", "price", "american", "bullet", "custom"
    - `:nominal_amount` [integer]: amount in cents transferred to the credit receiver, before deductions. ex: 11234 (= R$ 112.34)
    - `:scheduled` [Date, DateTime or binary]: date of transfer execution. ex: ~D[2020, 3, 10]
    - `:tax_id` [binary]: credit receiver's tax ID (CPF or CNPJ). ex: "20.018.183/0001-80"

  ## Parameters (conditionally required):
    - `:invoices` [list of CreditNote.Invoice objects]: list of Invoice objects to be created and sent to the credit receiver. ex: [Invoice(), Invoice()]
    - `:nominal_interest` [float]: yearly nominal interest rate of the CreditNote, in percentage. ex: 12.5
    - `:initial_due` [Date, DateTime or binary]: date of the first invoice. ex: ~D[2020, 3, 10]
    - `:count` [integer]: quantity of invoices for payment. ex: 12
    - `:initial_amount` [integer]: value of the first invoice in cents. ex: 1234 (= R$12.34)
    - `:interval` [binary]: interval between invoices. ex: "year", "month"

  ## Parameters (optional):
    - `:rebate_amount` [integer, default nil]: credit analysis fee deducted from lent amount. ex: 11234 (= R$ 112.34)

  ## Attributes (return-only):
    - `:amount` [integer]: CreditNote value in cents. ex: 1234 (= R$ 12.34)
    - `:interest` [float]: yearly effective interest rate of the CreditNote, in percentage. ex: 12.5
    - `:tax_amount` [integer]: tax amount included in the CreditNote. ex: 100
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
  def resource() do
    {
      "CreditNotePreview",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %CreditNotePreview{
      type: json[:type],
      nominal_amount: json[:nominal_amount],
      scheduled: json[:scheduled],
      tax_id: json[:tax_id],
      invoices: json[:invoices],
      nominal_interest: json[:nominal_interest],
      initial_due: json[:initial_due],
      count: json[:count],
      initial_amount: json[:initial_amount],
      interval: json[:interval],
      rebate_amount: json[:rebate_amount],
      amount: json[:amount],
      interest: json[:interest],
      tax_amount: json[:tax_amount],
    }
  end
end
