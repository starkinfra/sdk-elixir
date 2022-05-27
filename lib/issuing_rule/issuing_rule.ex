defmodule StarkInfra.IssuingRule do
    alias __MODULE__, as: IssuingRule

    @moduledoc """
        # IssuingRule struct
    """

    @doc """
    The IssuingRule struct displays the spending rules of IssuingCards and IssuingHolders created in your Workspace.

    ## Parameters (required):
        - `:name` [string]: rule name. ex: "Travel" or "Food"
        - `:amount` [integer]: maximum amount that can be spent in the informed interval. ex: 200000 (= R$ 2000.00)
        - `:interval` [string]: interval after which the rule amount counter will be reset to 0. ex: "instant", "day", "week", "month", "year" or "lifetime"

    ## Parameters (optional):
        - `:currency_code` [string, default "BRL"]: code of the currency that the rule amount refers to. ex: "BRL" or "USD"
        - `:categories` [list of strings, default []]: merchant categories accepted by the rule. ex: ["eatingPlacesRestaurants", "travelAgenciesTourOperators"]
        - `:countries` [list of strings, default []]: countries accepted by the rule. ex: ["BRA", "USA"]
        - `:methods` [list of strings, default []]: card purchase methods accepted by the rule. ex: ["chip", "token", "server", "manual", "magstripe", "contactless"]

    ## Attributes (expanded return-only):
        - `:counter_amount` [integer]: current rule spent amount. ex: 1000
        - `:currency_symbol` [string]: currency symbol. ex: "R$"
        - `:currency_name` [string]: currency name. ex: "Brazilian Real"

    ## Attributes (return-only):
        - `:id` [string]: unique id returned when Rule is created. ex: "5656565656565656"
    """
    @enforce_keys [
        :amount,
        :currency_code,
        :interval,
        :name
    ]
    defstruct [
        :amount,
        :currency_code,
        :id,
        :interval,
        :name
    ]

    @type t() :: %__MODULE__{}

    @doc false
    def resource() do
        {
            "IssuingRule",
            &resource_maker/1
        }
    end

    @doc false
    def resource_maker(json) do
        %IssuingRule{
            amount: json[:amount],
            currency_code: json[:currency_code],
            id: json[:id],
            interval: json[:interval],
            name: json[:name]
        }
    end

end
