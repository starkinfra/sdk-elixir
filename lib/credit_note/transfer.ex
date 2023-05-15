defmodule StarkInfra.CreditNote.Transfer do
  alias __MODULE__, as: Transfer

  @moduledoc """
  Groups Transfer related functions
  """

  @doc """
  Transfer sent to the credit receiver after the contract is signed.

  ## Parameters (required):
    - `:name` [binary]: receiver full name. ex: "Anthony Edward Stark"
    - `:tax_id` [binary]: receiver tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:bank_code` [binary]: code of the receiver Bank institution in Brazil. ex: "20018183" or "341"
    - `:branch_code` [binary]: receiver Bank account branch. Use '-' in case there is a verifier digit. ex: "1357-9"
    - `:account_number` [binary]: Receiver Bank account number. Use '-' before the verifier digit. ex: "876543-2"

  ## Parameters (optional):
    - `:account_type` [binary, default "checking"]: Receiver Bank account type. This parameter only has effect on Pix Transfers. ex: "checking", "savings", "salary" or "payment"
    - `:tags` [list of binaries, default []]: list of binaries for reference when searching for transfers. ex: ["employees", "monthly"]

    Attributes (return-only):
    - `:id` [binary]: unique id returned when Transfer is created. ex: "5656565656565656"
    - `:amount` [integer]: amount in cents to be transferred. ex: 1234 (= R$ 12.34)
    - `:external_id` [binary]: url safe string that must be unique among all your transfers. Duplicated external_ids will cause failures. By default, this parameter will block any transfer that repeats amount and receiver information on the same date. ex: "my-internal-id-123456"
    - `:scheduled` [Date, DateTime or binary, default now]: date or datetime when the transfer will be processed. May be pushed to next business day if necessary. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:description` [binary]: optional description to override default description to be shown in the bank statement. ex: "Payment for service #1234"
    - `:fee` [integer]: fee charged when the Transfer is processed. ex: 200 (= R$ 2.00)
    - `:status` [binary]: current transfer status. ex: "success" or "failed"
    - `:transaction_ids` [list of binaries]: ledger Transaction IDs linked to this Transfer (if there are two, the second is the chargeback). ex: ["19827356981273"]
    - `:created` [DateTime]: creation DateTime for the CreditNote. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update DateTime for the CreditNote. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :name,
    :tax_id,
    :bank_code,
    :branch_code,
    :account_number
  ]
  defstruct [
    :name,
    :tax_id,
    :bank_code,
    :branch_code,
    :account_number,
    :account_type,
    :tags,
    :id,
    :amount,
    :external_id,
    :scheduled,
    :description,
    :fee,
    :status,
    :transaction_ids,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def resource_maker(json) do
    %Transfer{
      name: json[:name],
      tax_id: json[:tax_id],
      bank_code: json[:bank_code],
      branch_code: json[:branch_code],
      account_number: json[:account_number],
      account_type: json[:account_type],
      tags: json[:tags],
      id: json[:id],
      amount: json[:amount],
      external_id: json[:external_id],
      scheduled: json[:scheduled],
      description: json[:description],
      fee: json[:fee],
      status: json[:status],
      transaction_ids: json[:transaction_ids],
      created: json[:created],
      updated: json[:updated]
    }
  end
end
