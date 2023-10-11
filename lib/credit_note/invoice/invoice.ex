defmodule StarkInfra.CreditNote.Invoice do
  alias __MODULE__, as: Invoice
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.API

  @moduledoc """
  Groups Invoice related functions
  """

  @doc """
  Invoice issued after the contract is signed, to be paid by the credit receiver.

  ## Parameters (required):
    - `:amount` [integer]: Invoice value in cents. Minimum = 1 (any value will be accepted). ex: 1234 (= R$ 12.34)

    ## Parameters (optional):
    - `:due` [DateTime, Date or binary, default now + 2 days]: Invoice due date in UTC ISO format. ex: ~U[2021-03-26 19:32:35.418698Z] for immediate invoices and ~D[2020-10-28] for scheduled invoices
    - `:expiration` [integer, default 5097600 (59 days)]: time interval in seconds between due date and expiration date. ex 123456789
    - `:tags` [list of binaries, default []]: list of binaries for tagging
    - `:descriptions` [list of CreditNote.Invoice.Description objects or maps, default []]: list of Descriptions

    ## Attributes (return-only):
    - `:id` [binary]: unique id returned when Invoice is created. ex: "5656565656565656"
    - `:name` [binary]: payer name. ex: "Iron Bank S.A."
    - `:tax_id` [binary]: payer tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:pdf` [binary]: public Invoice PDF URL. ex: "https://invoice.starkbank.com/pdf/d454fa4e524441c1b0c1a729457ed9d8"
    - `:link` [binary]: public Invoice webpage URL. ex: "https://my-workspace.sandbox.starkbank.com/invoicelink/d454fa4e524441c1b0c1a729457ed9d8"
    - `:fine` [float]: Invoice fine for overdue payment in %. ex: 2.5
    - `:interest` [float]: Invoice monthly interest for overdue payment in %. ex: 5.2
    - `:nominal_amount` [integer]: Invoice emission value in cents (will change if invoice is updated, but not if it's paid). ex: 400000
    - `:fine_amount` [integer]: Invoice fine value calculated over nominal_amount. ex: 20000
    - `:interest_amount` [integer]: Invoice interest value calculated over nominal_amount. ex: 10000
    - `:discount_amount` [integer]: Invoice discount value calculated over nominal_amount. ex: 3000
    - `:discounts` [list of CreditNote.Invoice.Discount objects or maps]: list of Discounts or maps with "percentage":float and "due":binary pairs
    - `:brcode` [binary]: BR Code for the Invoice payment. ex: "00020101021226800014br.gov.bcb.pix2558invoice.starkbank.com/f5333103-3279-4db2-8389-5efe335ba93d5204000053039865802BR5913Arya Stark6009Sao Paulo6220051656565656565656566304A9A0"
    - `:status` [binary]: current Invoice status. ex: "registered" or "paid"
    - `:fee` [integer]: fee charged by this Invoice. ex: 200 (= R$ 2.00)
    - `:transaction_ids` [list of binaries]: ledger transaction ids linked to this Invoice (if there are more than one, all but the first are reversals or failed reversal chargebacks). ex: ["19827356981273"]
    - `:created` [DateTime]: creation DateTime for the CreditNote. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update DateTime for the CreditNote. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :amount,
    :due
  ]
  defstruct [
    :id,
    :amount,
    :due,
    :expiration,
    :fine,
    :interest,
    :tags,
    :descriptions,
    :tax_id,
    :name,
    :pdf,
    :link,
    :nominal_amount,
    :fine_amount,
    :interest_amount,
    :discount_amount,
    :discounts,
    :brcode,
    :status,
    :fee,
    :transaction_ids,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def resource_maker(json) do
    %Invoice{
      id: json[:id],
      amount: json[:amount],
      due: json[:due] |> Check.date_or_datetime(),
      expiration: json[:expiration],
      fine: json[:fine],
      interest: json[:interest],
      tags: json[:tags],
      descriptions: json[:descriptions] |> Enum.map(fn descriptions -> API.from_api_json(descriptions, &Invoice.Description.resource_maker/1) end),
      tax_id: json[:tax_id],
      name: json[:name],
      pdf: json[:pdf],
      link: json[:link],
      nominal_amount: json[:nominal_amount],
      fine_amount: json[:fine_amount],
      interest_amount: json[:interest_amount],
      discount_amount: json[:discount_amount],
      discounts: json[:discounts] |> Enum.map(fn discounts -> API.from_api_json(discounts, &Invoice.Discount.resource_maker/1) end),
      brcode: json[:brcode],
      status: json[:status],
      fee: json[:fee],
      transaction_ids: json[:transaction_ids],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
