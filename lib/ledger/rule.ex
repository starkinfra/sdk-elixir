defmodule StarkInfra.Ledger.Rule do
  alias __MODULE__, as: Rule

  @moduledoc """
  Groups Ledger.Rule related functions
  """

  @doc """
  The Ledger.Rule object modifies the behavior of Ledger objects when passed
  as an argument upon their creation or update.

  ## Parameters (required):
    - `:key` [string]: rule to be customized, describes what Ledger behavior will be altered. ex: "minimumBalance", "maximumBalance"
    - `:value` [integer]: value of the rule. ex: 1000
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
