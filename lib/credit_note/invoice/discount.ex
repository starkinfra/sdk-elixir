defmodule StarkInfra.CreditNote.Invoice.Discount do
  alias __MODULE__, as: Discount
  alias StarkInfra.Utils.Check

  @moduledoc """
  Groups Discount related functions
  """

  @doc """
  Invoice discount information.

  ## Parameters (required):
    - `:percentage` [float]: percentage of discount applied until specified due date
    - `:due` [DateTime, Date or binary]: due datetime for the discount
  """
  @enforce_keys [
    :percentage,
    :due
  ]
  defstruct [
    :percentage,
    :due
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def resource_maker(json) do
    %Discount{
      percentage: json[:percentage],
      due: json[:due] |> Check.date_or_datetime()
    }
  end
end
