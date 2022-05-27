defmodule StarkInfra.IssuingInvoice do
    alias __MODULE__, as: IssuingInvoice
    alias StarkInfra.Utils.Rest
    alias StarkInfra.Utils.Check
    alias StarkInfra.User.Project
    alias StarkInfra.User.Organization
    alias StarkInfra.Error

    @moduledoc """
        # IssuingInvoice struct
    """

    @doc """
    The IssuingInvoice structs created in your Workspace load your Issuing balance when paid.

    ## Parameters (required):
        - `:amount` [integer]: IssuingInvoice value in cents. ex: 1234 (= R$ 12.34)

    ## Parameters (optional):
        - `:tax_id` [string, default sub-issuer tax ID]: payer tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
        - `:name` [string, default sub-issuer name]: payer name. ex: "Iron Bank S.A."
        - `:tags` [list of strings, default []]: list of strings for tagging. ex: ["travel", "food"]

    ## Attributes (return-only):
        - `:id` [string]: unique id returned when IssuingInvoice is created. ex: "5656565656565656"
        - `:status` [string]: current IssuingInvoice status. ex: "created", "expired", "overdue", "paid"
        - `:issuing_transaction_id` [string]: ledger transaction ids linked to this IssuingInvoice. ex: "issuing-invoice/5656565656565656"
        - `:updated` [DateTime]: latest update DateTime for the IssuingInvoice. ex: ~U[2020-3-10 10:30:0:0]
        - `:created` [DateTime]: creation datetime for the IssuingInvoice. ex: ~U[2020-03-10 10:30:0:0]
    """
    @enforce_keys [
        :amount
    ]
    defstruct [
        :amount,
        :tax_id,
        :name,
        :tags,
        :id,
        :status,
        :issuing_transaction_id,
        :updated,
        :created
    ]

    @type t() :: %__MODULE__{}

    @doc """
    Send a list of IssuingInvoice structs for creation in the Stark Infra API

    ## Parameters (required):
        - `:invoice` [IssuingInvoice struct]: IssuingInvoice struct to be created in the API.

    ## Options:
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - IssuingInvoice struct with updated attributes
    """
    @spec create(
        invoice: IssuingInvoice.t(),
        user: Organization.t() | Project.t() | nil
    ) ::
        {:ok, IssuingInvoice.t()} |
        {:error, [Error.t()]}
    def create(invoice, options \\ []) do
        Rest.post_single(
            resource(),
            invoice,
            options
        )
    end

    @doc """
    Same as create(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec create!(
        invoice: IssuingInvoice.t(),
        user: Organization.t() | Project.t() | nil
    ) :: any
    def create!(invoice, options \\ []) do
        Rest.post_single!(
            resource(),
            invoice,
            options
        )
    end

    @doc """
    Receive a single IssuingInvoice struct previously created in the Stark Infra API by its id

    ## Parameters (required):
        - `:id` [string]: struct unique id. ex: "5656565656565656"

    ## Options:
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - IssuingInvoice struct with updated attributes
    """
    @spec get(
        id: binary,
        user: Organization.t() | Project.t() | nil
    ) ::
        {:ok, IssuingInvoice.t()} |
        {:error, [Error.t()]}
    def get(id, options \\ []) do
        Rest.get_id(
            resource(),
            id,
            options
        )
    end

    @doc """
    Same as get(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec get!(
        id: binary,
        user: Organization.t() | Project.t() | nil
    ) :: any
    def get!(id, options \\ []) do
        Rest.get_id!(
            resource(),
            id,
            options
        )
    end

    @doc """
    Receive a stream of IssuingInvoices structs previously created in the Stark Infra API

    ## Options:
        - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
        - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
        - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
        - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "expired", "overdue", "paid"]
        - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - stream of IssuingInvoices structs with updated attributes
    """
    @spec query(
        limit: integer | nil,
        after: Date.t() | binary | nil,
        before: Date.t() | binary | nil,
        status: [binary] | nil,
        tags: [binary] | nil,
        user: Organization.t() | Project.t() | nil
    ) ::
        {:ok, {binary, [IssuingInvoice.t()]}} |
        {:error, [Error.t()]}
    def query(options \\ []) do
        Rest.get_list(
            resource(),
            options
        )
    end

    @doc """
    Same as query(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec query!(
        limit: integer | nil,
        after: Date.t() | binary | nil,
        before: Date.t() | binary | nil,
        status: [binary] | nil,
        tags: [binary] | nil,
        user: Organization.t() | Project.t() | nil
    ) :: any
    def query!(options \\ []) do
        Rest.get_list!(
            resource(),
            options
        )
    end

    @doc """
    Receive a list of IssuingInvoices structs previously created in the Stark Infra API and the cursor to the next page.

    ## Options:
        - `:cursor` [string, default nil]: cursor returned on the previous page function call
        - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
        - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
        - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
        - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "expired", "overdue", "paid"]
        - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - list of IssuingInvoices structs with updated attributes
        - cursor to retrieve the next page of IssuingInvoices structs
    """
    @spec page(
        cursor: binary | nil,
        limit: integer | nil,
        after: Date.t() | binary | nil,
        before: Date.t() | binary | nil,
        status: [binary] | nil,
        tags: [binary] | nil,
        user: Organization.t() | Project.t() | nil
    ) ::
        {:ok, {binary, [IssuingInvoice.t()]}} |
        {:error, [Error.t()]}
    def page(options \\ []) do
        Rest.get_page(
            resource(),
            options
        )
    end

    @doc """
    Same as page(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec page!(
        cursor: binary | nil,
        limit: integer | nil,
        after: Date.t() | binary | nil,
        before: Date.t() | binary | nil,
        status: [binary] | nil,
        tags: [binary] | nil,
        user: Organization.t() | Project.t() | nil
    ) :: any
    def page!(options \\ []) do
        Rest.get_page!(
            resource(),
            options
        )
    end

    @doc false
    def resource() do
        {
            "IssuingInvoice",
            &resource_maker/1
        }
    end

    @doc false
    def resource_maker(json) do
        %IssuingInvoice{
            amount: json[:amount],
            tax_id: json[:tax_id],
            name: json[:name],
            tags: json[:tags],
            id: json[:id],
            status: json[:status],
            issuing_transaction_id: json[:issuing_transaction_id],
            updated: json[:updated] |> Check.datetime(),
            created: json[:created] |> Check.datetime()
        }
    end
end
