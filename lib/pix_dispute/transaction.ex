defmodule StarkInfra.PixDispute.Transaction do
  alias __MODULE__, as: Transaction

  @moduledoc """
  Groups PixDispute.Transaction related functions
  """

  @doc """
  Transaction object related to the PixDispute.

  ## Attributes (return-only):
    - `:end_to_end_id` [string]: Central Bank's unique transaction id. ex: "E79457883202101262140HHX553UPqeq"
    - `:amount` [integer]: refundable amount. ex: 11234 (= R$ 112.34)
    - `:nominal_amount` [integer]: transaction amount. ex: 11234 (= R$ 112.34)
    - `:receiver_type` [string]: receiver person type. Options: "individual", "business"
    - `:receiver_tax_id_created` [string]: receiver's taxId creation date. For business type only.
    - `:receiver_account_created` [string]: receiver's account creation date.
    - `:receiver_bank_code` [string]: receiver's bank code. ex: "20018183"
    - `:receiver_id` [string]: identifier of accountholder in the graph.
    - `:sender_type` [string]: sender person type. Options: "individual", "business"
    - `:sender_tax_id_created` [string]: sender's taxId creation date. For business type only.
    - `:sender_account_created` [string]: sender's account creation date.
    - `:sender_bank_code` [string]: sender's bank code. ex: "20018183"
    - `:sender_id` [string]: identifier of accountholder in the graph.
    - `:settled` [string]: settled datetime of the transaction. ex: "2020-04-23T23:00:00.000000+00:00"
  """
  defstruct [
    :end_to_end_id,
    :amount,
    :nominal_amount,
    :receiver_type,
    :receiver_tax_id_created,
    :receiver_account_created,
    :receiver_bank_code,
    :receiver_id,
    :sender_type,
    :sender_tax_id_created,
    :sender_account_created,
    :sender_bank_code,
    :sender_id,
    :settled
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def resource_maker(json) do
    %Transaction{
      end_to_end_id: json[:end_to_end_id],
      amount: json[:amount],
      nominal_amount: json[:nominal_amount],
      receiver_type: json[:receiver_type],
      receiver_tax_id_created: json[:receiver_tax_id_created],
      receiver_account_created: json[:receiver_account_created],
      receiver_bank_code: json[:receiver_bank_code],
      receiver_id: json[:receiver_id],
      sender_type: json[:sender_type],
      sender_tax_id_created: json[:sender_tax_id_created],
      sender_account_created: json[:sender_account_created],
      sender_bank_code: json[:sender_bank_code],
      sender_id: json[:sender_id],
      settled: json[:settled]
    }
  end
end
