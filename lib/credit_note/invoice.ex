defmodule StarkInfra.CreditNote.Invoice do
    alias __MODULE__, as: Invoice
    alias StarkInfra.Utils.Check

    @moduledoc """
    Groups Invoice related functions
    """

    @doc """
    When you initialize an Invoice struct, the entity will not be automatically
    sent to the Stark Infra API. The 'create' function sends the structs
    to the Stark Infra API and returns the list of created structs.
    To create scheduled Invoices, which will display the discount, interest, etc. on the final users banking interface,
    use dates instead of datetimes on the "due" and "discounts" fields.

    ## Parameters (required):
        - `:amount` [integer]: Invoice value in cents. Minimum = 0 (any value will be accepted). ex: 1234 (= R$ 12.34)        
        - `:due` [DateTime, Date or string, default now + 2 days]: Invoice due date in UTC ISO format. ex: ~U[2021-03-26 19:32:35.418698Z] for immediate invoices and ~D[2020-10-28] for scheduled invoices

    ## Parameters (optional):                
        - `:expiration` [integer, default 59 days]: time interval in seconds between due date and expiration date. ex 123456789
        - `:fine` [float, default 0.0]: Invoice fine for overdue payment in %. ex: 2.5
        - `:interest` [float, default 0.0]: Invoice monthly interest for overdue payment in %. ex: 5.2
        - `:discounts` [list of dictionaries, default nil]: list of dictionaries with "percentage":float and "due":string pairs
        - `:tags` [list of strings, default nil]: list of strings for tagging
        - `:descriptions` [list of dictionaries, default nil]: list of dictionaries with "key":string and (optional) "value":string pairs

    ## Attributes (return-only):        
        - `:id` [string, default nil]: unique id returned when Invoice is created. ex: "5656565656565656"                
        - `:tax_id` [string]: payer tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
        - `:name` [string]: payer name. ex: "Iron Infra S.A."
    """


    @enforce_keys [        
        :amount,   
        :due
    ]
    defstruct [
        :id,
        :amount,
        :descriptions,
        :discounts,
        :due,
        :expiration,
        :fine,
        :interest,
        :name,
        :tags, 
        :tax_id
    ]

    @type t() :: %__MODULE__{}

    @doc false
    def resource_maker(json) do
        %Invoice{
            id: json[:id],
            amount: json[:amount],
            descriptions: json[:descriptions],
            discounts: json[:discounts] 
                |> Enum.map(fn discount -> %{discount | "due" => discount["due"] |> Check.date_or_datetime()} end),
            due: json[:due] |> Check.date_or_datetime(),
            expiration: json[:expiration],
            fine: json[:fine],
            interest: json[:interest],
            name: json[:name],
            tags: json[:tags],
            tax_id: json[:tax_id]
        }
    end
end
