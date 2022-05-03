defmodule StarkInfra.CreditNote do
    alias __MODULE__, as: CreditNote
    alias StarkInfra.CreditNote.Invoice
    alias StarkInfra.CreditNote.Transfer
    alias StarkInfra.Utils.Rest    
    alias StarkInfra.Utils.API
    alias StarkInfra.Utils.Check
    alias StarkInfra.User.Project
    alias StarkInfra.User.Organization
    alias StarkInfra.Error

    @moduledoc """
    # CreditNote object
        CreditNotes are used to generate CCB contracts between you and your customers.
        When you initialize a CreditNote, the entity will not be automatically
        created in the Stark Infra API. The 'create' function sends the objects
        to the Stark Infra API and returns the list of created objects.
    ## Parameters (required):
        - `:template_id` [string]: ID of the contract template on which the CreditNote will be based. ex: "0123456789101112"
        - `:external_id [string]: a string that must be unique among all your CreditNotes, used to avoid resource duplication. ex: “my-internal-id-123456”
        - `:name` [string]: credit receiver's full name. ex: "Anthony Edward Stark"
        - `:tax_id` [string]: credit receiver's tax ID (CPF or CNPJ). ex: "20.018.183/0001-80"
        - `:nominal_amount` [integer]: amount in cents transferred to the credit receiver, before deductions. ex: 11234 (= R$ 112.34)
        - `:scheduled` [Date or string,]: Date of transfer execution. ex: ~D[2020-03-10]
        - `:invoices` [list of Invoice objects]: list of Invoice objects to be created and sent to the credit receiver. ex: [%{ due: "2023-06-25", amount: 120000, fine: 10, interest: 2}]
        - `:transfer` [Transfer object]: Transfer object to be created and sent to the credit receiver. ex: %{ bankCode: "00000000", branchCode: "1234", accountNumber: "129340-1", name: "Jamie Lannister", taxId: "012.345.678-90"}
        - `:signers` [list of contacts]: name and e-mail of signers that sign the contract. ex: [%{"name": "Tony Stark", "contact": "tony@starkindustries.com", "method": "link"}]
    ## Parameters (optional):
        - `:rebate_amount` [integer, default 0]: credit analysis fee deducted from lent amount. ex: 11234 (= R$ 112.34)
        - `:tags` [list of strings, default []]: list of strings for reference when searching for CreditNotes. ex: [\"employees\", \"monthly\"]        
    ## Attributes (return-only):
        - `:id` [string, default nil]: unique id returned when the CreditNote is created. ex: "5656565656565656"
        - `:interest` [float]: yearly effective interest rate of the CreditNote, in percentage. ex: 12.5
        - `:created` [DateTime, default nil]: creation DateTime for the CreditNote. ex:  ~U[2020-3-10 10:30:0:0]
        - `:updated` [DateTime, default nil]: latest update DateTime for the CreditNote. ex: ~U[2020-3-10 10:30:0:0]
    """

    @enforce_keys [
        :template_id,
        :external_id,
        :name,
        :tax_id,
        :nominal_amount,
        :scheduled,
        :invoices,
        :transfer,
        :signers
    ]
    defstruct [
        :id,
        :template_id,
        :name,
        :tax_id,
        :nominal_amount,
        :scheduled,
        :invoices,
        :transfer,
        :signers,
        :interest,
        :rebate_amount,
        :tags,
        :created,
        :updated        
    ]

    @type t() :: %__MODULE__{}

    @doc """
    # Create CreditNotes
        Send a list of CreditNote objects for creation in the Stark Infra API
    ## Parameters (required):
        - `:notes` [list of CreditNote objects]: list of CreditNote objects to be created in the API
    ## Parameters (optional):
        - `:user` [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.User was set before function call
    ## Return:
        - `:list` of CreditNote objects with updated attributes
    """
    @spec create([CreditNote.t() | map()], user: Project.t() | Organization.t() | nil) ::
        { :ok, [CreditNote.t()]} | {:error, [Error.t()]}
    def create(notes, options \\ []) do
        Rest.post(
            resource(),
            notes,
            options
        )
    end

    @doc """
    Same as create(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec create([CreditNote.t() | map()], user: Project.t() | Organization.t() | nil) :: any
    def create!(notes, options \\ []) do
        Rest.post!(
            resource(),
            notes,
            options
        )
    end

    @doc """
    # Retrieve a specific CreditNote
        Receive a single CreditNote object previously created in the Stark Infra API by its id
    ## Parameters (required):
        - `:id` [string]: object unique id. ex: "5656565656565656"
    ## Parameters (optional):
        - `:user` [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.User was set before function call
    ## Return:
        - `:CreditNote` object with updated attributes
    """
    @spec get(binary, user: Project.t() | Organization.t() | nil) ::
        { :ok, [CreditNote.t()]} | {:error, [Error.t()]}
    def get(id, options \\ []) do 
        Rest.get_id(resource(), id, options)
    end 

    @doc """
        Same as get(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec get!(binary, user: Project.t() | Organization.t() | nil) :: any
    def get!(id, options \\ []) do 
        Rest.get_id!(resource(), id, options)
    end
    
    @doc """
    # Retrieve CreditNotes
        Receive a generator of CreditNote objects previously created in the Stark Bank API
    ## Parameters (optional):
        - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
        - `:after` [Date or string, default nil] date filter for objects created only after specified date. ex: ~D[2020, 3, 10]
        - `:before` [Date or string, default nil] date filter for objects created only before specified date. ex: ~D[2020, 3, 10]
        - `:status` [string, default nil]: filter for status of retrieved objects. ex: "paid" or "registered"
        - `:tags` [list of strings, default []]: tags to filter retrieved objects. ex: ["tony", "stark"]
        - `:ids` [list of strings, default []]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
        - `:user` [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.User was set before function call
    ## Return:
        - `:generator` of CreditNote objects with updated attributes
    """
    @spec query(
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        status: binary, 
        tags: [binary],
        ids: [binary],
        user: Project.t() | Organization.t() | nil
    ) :: 
    ({:cont, {:ok, [CreditNote.t()]}}
     | {:error, [Error.t()]}
     | {:halt, any}
     | {:suspend, any},
      any -> 
        any)
    def query(options \\ []) do
        Rest.get_list(resource(), options)
    end

    @doc """
    Same as query(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec query!(
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        status: binary, 
        tags: [binary],
        ids: [binary],
        user: Project.t() | Organization.t() | nil
    ) ::
    ( {:cont, [CreditNote.t()]}
     | {:error, [Error.t()]}
     | {:halt, any}
     | {:suspend, any},
      any -> 
        any)
    def query!(options \\ []) do
        Rest.get_list!(resource(), options)
    end

    @doc """
    # Retrieve paged CreditNotes
        Receive a list of up to 100 CreditNote objects previously created in the Stark Bank API and the cursor to the next page.
        Use this function instead of query if you want to manually page your requests.
    ## Parameters (optional):
        - `:cursor` [string, default nil]: cursor returned on the previous page function call
        - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
        - `:after` [Date or string, default nil] Date filter for objects created only after specified date. ex: ~D[2020-3-10]
        - `:before` [Date or string, default nil] Date filter for objects created only before specified date. ex: ~D(2020-3-10]
        - `:status` [string, default nil]: filter for status of retrieved objects. ex: "paid" or "registered"
        - `:tags` [list of strings, default []]: tags to filter retrieved objects. ex: ["tony", "stark"]
        - `:ids` [list of strings, default []]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
        - `:user` [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.User was set before function call
    ## Return:
        - `:list` of CreditNote objects with updated attributes
        - `:cursor` to retrieve the next page of CreditNote objects
    """
    @spec page(
        cursor: binary,
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        status: binary, 
        tags: [binary],
        ids: [binary],
        user: Project.t() | Organization.t() | nil
    ) :: 
    {:ok, {binary, [CreditNote.t()]}} | {:error, [Error.t()]}
    def page(options \\ []) do 
        Rest.get_page(resource(), options)
    end

    @doc """
    Same as page(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec page!(
        cursor: binary,
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        status: binary, 
        tags: [binary],
        ids: [binary],
        user: Project.t() | Organization.t() | nil
    ) ::
       [CreditNote.t()]
    def page!(options \\ []) do 
        Rest.get_page!(resource(), options)
    end

    @doc """
    # Cancel a CreditNote entity
        Cancel a CreditNote entity previously created in the Stark Infra API
    ## Parameters (required):
        - `:id` [string]: id of the CreditNote to be canceled
    ## Parameters (optional):
        - `:user` [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkbank.user was set before function call
    ## Return:
        credit_note [CreditNote.t()]: canceled CreditNote object
    """    
    @spec delete(binary, user: Project.t() | Organization.t() | nil) ::
    { :ok, CreditNote.t()} | {:error, [Error.t()]}
    def delete(id, options \\ []) do 
        Rest.delete_id(resource(), id, options)
    end 

    @doc """
    Same as delete(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec delete!(binary, user: Project.t() | Organization.t() | nil) :: CreditNote.t()
    def delete!(id, options \\ []) do 
        Rest.delete_id!(resource(), id, options)
    end

    @doc false
    def resource() do 
        {
            "CreditNote",
            &resource_maker/1
        }
    end

    @doc false
    def resource_maker(json) do
        %CreditNote{
            template_id: json[:template_id],
            name: json[:name],
            tax_id: json[:tax_id],
            nominal_amount: json[:nominal_amount],
            scheduled: json[:scheduled],
            invoices: json[:invoices] |> Enum.map(fn invoice -> API.from_api_json(invoice, &Invoice.resource_maker/1) end),
            transfer: json[:transfer] |> API.from_api_json(&Transfer.resource_maker/1),
            signers: json[:signers],
            external_id: json[:external_id],
            interest: json[:interest],
            rebate_amount: json[:rebate_amount],
            tags: json[:tags],
            created: json[:created] |> Check.datetime(),
            updated: json[:updated] |> Check.datetime(),
            id: json[:id]
        }
    end

end
