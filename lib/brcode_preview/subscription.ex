defmodule StarkInfra.BrcodePreview.Subscription do
  alias __MODULE__, as: Subscription
  alias StarkInfra.Utils.Check

  @moduledoc """
  Groups BrcodePreview.Subscription related functions
  """

  @doc """
  A BrcodePreview.Subscription is a read-only snapshot of a Pix recurring-debit
  subscription, embedded inside a BrcodePreview response when the previewed BR Code
  carries subscription metadata. It is never persisted by the caller and exposes no
  endpoints.

  ## Attributes (return-only):
    - `:amount` [integer]: amount in cents charged per cycle. nil for variable-amount subscriptions. ex: 1000 (= R$ 10.00)
    - `:amount_min_limit` [integer]: floor value for the maximum amount the sender can set when approving a variable-amount subscription. nil for fixed-amount subscriptions. ex: 500 (= R$ 5.00)
    - `:bacen_id` [string]: Central Bank's unique recurrency id for the subscription.
    - `:created` [DateTime]: creation datetime of the subscription. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:description` [string]: additional information delivered to the sender.
    - `:installment_end` [DateTime]: end datetime of settlements allowed for this subscription. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:installment_start` [DateTime]: start datetime of settlements allowed for this subscription. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:interval` [string]: cycle definition exposed verbatim from the server. ex: "monthly"
    - `:pull_retry_limit` [integer]: max number of retries the receiver may issue for a single failed pull cycle.
    - `:receiver_bank_code` [string]: receiver's bank institution code.
    - `:receiver_name` [string]: receiver's full name.
    - `:receiver_tax_id` [string]: receiver's tax id (CPF or CNPJ).
    - `:reference_code` [string]: commercial-relation identifier (contract number, order id, or client code).
    - `:sender_final_name` [string]: final sender name when the sender differs from the originating institution.
    - `:sender_final_tax_id` [string]: final sender tax id when distinct from the originating sender.
    - `:status` [string]: current lifecycle state of the subscription snapshot, verbatim from the server. ex: "created", "active", "canceled" or "failed"
    - `:type` [string]: subscription journey type, verbatim from the server. ex: "push", "subscriptionAndPayment"
    - `:updated` [DateTime]: latest update datetime of the subscription. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  defstruct [
    :amount,
    :amount_min_limit,
    :bacen_id,
    :created,
    :description,
    :installment_end,
    :installment_start,
    :interval,
    :pull_retry_limit,
    :receiver_bank_code,
    :receiver_name,
    :receiver_tax_id,
    :reference_code,
    :sender_final_name,
    :sender_final_tax_id,
    :status,
    :type,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def resource_maker(json) do
    %Subscription{
      amount: json[:amount],
      amount_min_limit: json[:amount_min_limit],
      bacen_id: json[:bacen_id],
      created: json[:created] |> Check.datetime(),
      description: json[:description],
      installment_end: json[:installment_end] |> Check.datetime(),
      installment_start: json[:installment_start] |> Check.datetime(),
      interval: json[:interval],
      pull_retry_limit: json[:pull_retry_limit],
      receiver_bank_code: json[:receiver_bank_code],
      receiver_name: json[:receiver_name],
      receiver_tax_id: json[:receiver_tax_id],
      reference_code: json[:reference_code],
      sender_final_name: json[:sender_final_name],
      sender_final_tax_id: json[:sender_final_tax_id],
      status: json[:status],
      type: json[:type],
      updated: json[:updated] |> Check.datetime()
    }
  end
end
