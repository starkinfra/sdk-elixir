defmodule StarkInfra.CreditNote.Rule do
  alias __MODULE__, as: Rule

  @moduledoc """
  Groups CreditNote.Rule related functions
  """

  @doc """
  The CreditNote.Rule object modifies the behavior of CreditNote structs when passed
  as an argument upon their creation.

  ## Parameters (required):
    - `:key` [string]: rule to be customized, describes what CreditNote behavior will be altered. ex: "invoiceCreationMode"
    - `:value` [string]: value of the rule. ex: "scheduled", "instant", "never"
  """
  @enforce_keys [
    :key,
    :value
  ]
  defstruct [
    :key,
    :value
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def resource_maker(json) do
    %Rule{
      key: json[:key],
      value: json[:value]
    }
  end
end
