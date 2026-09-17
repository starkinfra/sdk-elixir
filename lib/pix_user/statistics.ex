defmodule StarkInfra.PixUser.Statistics do
  alias __MODULE__, as: Statistics
  alias StarkInfra.Utils.Check

  @moduledoc """
  Groups PixUser.Statistics related functions
  """

  @doc """
  The PixUser.Statistics struct stores fraud statistics data of a Pix user.

  ## Attributes (return-only):
    - `:value` [integer]: aggregated value of the statistic. ex: 3
    - `:type` [string]: type of the statistic. Options: "registered", "unique" (pix-key); "settled" (pix-request); "identity", "mule", "scam", "other" (pix-fraud); "infractions" (pix-infraction)
    - `:source` [string]: source of the statistic. Options: "pix-key", "pix-fraud", "pix-request", "pix-infraction"
    - `:after` [DateTime]: start datetime considered for the statistic aggregation. ex: ~U[2020-04-23 23:00:00.000000Z]
    - `:updated` [DateTime]: latest update datetime for the statistic. ex: ~U[2020-04-23 23:00:00.000000Z]
  """
  defstruct [
    :value,
    :type,
    :source,
    :after,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def resource_maker(json) do
    %Statistics{
      value: json[:value],
      type: json[:type],
      source: json[:source],
      after: json[:after] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
