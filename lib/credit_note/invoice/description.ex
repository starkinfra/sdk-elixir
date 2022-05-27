defmodule StarkInfra.CreditNote.Invoice.Description do
    alias __MODULE__, as: Description

    @moduledoc """
    Groups Description related functions
    """

    @doc """
    Invoice description information.

    ## Parameters (required):
        - `:key` [string]: Description for the value. ex: "Taxes"

    ## Parameters (optional):
        - `:value` [string, nil]: amount related to the described key. ex: "R$100,00"
    """
    @enforce_keys [
        :key
    ]
    defstruct [
        :key,
        :value
    ]

    @type t() :: %__MODULE__{}

    @doc false
    def resource_maker(json) do
        %Description{
            key: json[:key],
            value: json[:value]
        }
    end
end
