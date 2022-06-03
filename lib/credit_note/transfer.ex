defmodule StarkInfra.CreditNote.Transfer do
  alias __MODULE__, as: Transfer
  alias StarkInfra.Utils.Check

  @moduledoc """
  Groups Transfer related functions
  """

  @doc """
  CreditNote signer's information.

  ## Parameters (required):
    - `:name` [string]: receiver full name. ex: "Anthony Edward Stark"
    - `:tax_id` [string]: receiver tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:bank_code` [string]: code of the receiver Bank institution in Brazil.
    - `:branch_code` [string]: receiver Bank account branch. Use '-' in case there is a verifier digit. ex: "1357-9"
    - `:account_number` [string]: Receiver Bank account number. Use '-' before the verifier digit. ex: "876543-2"

  ## Options:
    - `:account_type` [string, default "checking"]: Receiver Bank account type. This parameter only has effect on Pix Transfers. ex: "checking", "savings", "salary" or "payment"
    - `:scheduled` [Date, DateTime or string, default now]: date or datetime when the transfer will be processed. May be pushed to next business day if necessary. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:tags` [list of strings]: list of strings for reference when searching for transfers. ex: ["employees", "monthly"]

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when Transfer is created. ex: "5656565656565656"
    - `:amount` [integer]: amount in cents to be transferred. ex: 1234 (= R$ 12.34)
    - `:status` [string, default nil]: current transfer status. ex: "success" or "failed"
  """
  @enforce_keys [
    :bank_code,
    :branch_code,
    :account_number,
    :name,
    :tax_id
  ]
  defstruct [
    :account_number,
    :account_type,
    :amount,
    :bank_code,
    :branch_code,
    :id,
    :name,
    :scheduled,
    :status,
    :tags,
    :tax_id
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def resource_maker(json) do
    %Transfer{
      account_number: json[:account_number],
      account_type: json[:account_type],
      amount: json[:amount],
      bank_code: json[:bank_code],
      branch_code: json[:branch_code],
      id: json[:id],
      name: json[:name],
      scheduled: json[:scheduled] |> Check.datetime(),
      status: json[:status],
      tags: json[:tags],
      tax_id: json[:tax_id]
    }
  end
end
