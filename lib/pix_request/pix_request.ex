defmodule StarkInfra.PixRequest do
    alias __MODULE__, as: PixRequest
    alias StarkInfra.User.Organization
    alias StarkInfra.User.Project
    alias StarkInfra.Utils.Parse
    alias StarkInfra.Utils.Check
    alias StarkInfra.Utils.Rest
    alias StarkInfra.Error

    @moduledoc """
    Groups PixRequest related functions
    """

    @doc """
    PixRequests are used to receive or send instant payments to accounts
    hosted in any Pix participant.
    When you initialize a PixRequest, the entity will not be automatically
    created in the Stark Infra API. The 'create' function sends the structs
    to the Stark Infra API and returns the list of created structs.

    ## Parameters (required):
        - `:amount` [integer]: amount in cents to be transferred. ex: 11234 (= R$ 112.34)
        - `:external_id` [string]: string that must be unique among all your PixRequests. Duplicated external IDs will cause failures. By default, this parameter will block any PixRequests that repeats amount and receiver information on the same date. ex: "my-internal-id-123456"
        - `:sender_name` [string]: sender's full name. ex: "Edward Stark"
        - `:sender_tax_id` [string]: sender's tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
        - `:sender_branch_code` [string]: sender's bank account branch code. Use '-' in case there is a verifier digit. ex: "1357-9"
        - `:sender_account_number` [string]: sender's bank account number. Use '-' before the verifier digit. ex: "876543-2"
        - `:sender_account_type` [string, default "checking"]: sender's bank account type. ex: "checking", "savings", "salary" or "payment"
        - `:receiver_name` [string]: receiver's full name. ex: "Edward Stark"
        - `:receiver_tax_id` [string]: receiver's tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
        - `:receiver_bank_code` [string]: receiver's bank institution code in Brazil. ex: "20018183"
        - `:receiver_account_number` [string]: receiver's bank account number. Use '-' before the verifier digit. ex: "876543-2"
        - `:receiver_branch_code` [string]: receiver's bank account branch code. Use '-' in case there is a verifier digit. ex: "1357-9"
        - `:receiver_account_type` [string]: receiver's bank account type. ex: "checking", "savings", "salary" or "payment"
        - `:end_to_end_id` [string]: central bank's unique transaction ID. ex: "E79457883202101262140HHX553UPqeq"

    ## Parameters (optional):
        - `:receiver_key_id` [string, default nil]: receiver's dict key. ex: "20.018.183/0001-80"
        - `:description` [string, default nil]: optional description to override default description to be shown in the bank statement. ex: "Payment for service #1234"
        - `:reconciliation_id` [string, default nil]: Reconciliation ID linked to this payment. ex: "b77f5236-7ab9-4487-9f95-66ee6eaf1781"
        - `:initiator_tax_id` [string, default nil]: Payment initiator's tax id (CPF/CNPJ). ex: "01234567890" or "20.018.183/0001-80"
        - `:cash_amount` [integer, default nil]: Amount to be withdrawal from the cashier in cents. ex: 1000 (= R$ 10.00)
        - `:cashier_bank_code` [string, default nil]: Cashier's bank code. ex: "00000000"
        - `:cashier_type` [string, default nil]: Cashier's type. ex: [merchant, other, participant]
        - `:tags` [list of strings, default nil]: list of strings for reference when searching for PixRequests. ex: ["employees", "monthly"]
        - `:method` [string, default nil]: execution  method for thr creation of the PIX. ex: "manual", "payerQrcode", "dynamicQrcode".

    ## Attributes (return-only):
        - `:id` [string]: unique id returned when the PixRequest is created. ex: "5656565656565656"
        - `:fee` [integer]: fee charged when PixRequest is paid. ex: 200 (= R$ 2.00)
        - `:status` [string]: current PixRequest status. Options: “created”, “processing”, “success”, “failed”
        - `:flow` [string]: direction of money flow. ex: "in" or "out"
        - `:sender_bank_code` [string]: sender's bank institution code in Brazil. ex: "20018183"
        - `:created` [DateTime]: creation datetime for the PixRequest. ex: ~U[2020-03-10 10:30:0:0]
        - `:updated` [DateTime]: latest update datetime for the PixRequest. ex: ~U[2020-03-10 10:30:0:0]
    """
    @enforce_keys [
        :amount,
        :external_id,
        :sender_name,
        :sender_tax_id,
        :sender_branch_code,
        :sender_account_number,
        :sender_account_type,
        :receiver_name,
        :receiver_tax_id,
        :receiver_bank_code,
        :receiver_account_number,
        :receiver_branch_code,
        :receiver_account_type,
        :end_to_end_id,
    ]

    defstruct [
        :amount,
        :external_id,
        :sender_name,
        :sender_tax_id,
        :sender_branch_code,
        :sender_account_number,
        :sender_account_type,
        :receiver_name,
        :receiver_tax_id,
        :receiver_bank_code,
        :receiver_account_number,
        :receiver_branch_code,
        :receiver_account_type,
        :end_to_end_id,
        :receiver_key_id,
        :description,
        :reconciliation_id,
        :initiator_tax_id,
        :cash_amount,
        :cashier_bank_code,
        :cashier_type,
        :tags,
        :method,
        :id,
        :fee,
        :status,
        :flow,
        :sender_bank_code,
        :created,
        :updated
    ]

    @type t() :: %__MODULE__{}

    @doc """
    Send a list of PixRequest structs for creation in the Stark Infra API

    ## Parameters (required):
        - `:requests` [list of PixRequest structs]: list of PixRequest structs to be created in the API

    ## Options:
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - `:list of PixRequest structs with updated attributes
    """
    @spec create(
        [PixRequest.t() | map()],
        user: Project.t() | Organization.t() | nil
    )::
        {:ok, [PixRequest.t()]} |
        {:error, [error: Error.t()]}
    def create(requests, options \\ []) do
        Rest.post(
            resource(),
            requests,
            options
        )
    end

    @doc """
    Same as create(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec create!(
        [PixRequest.t() | map()],
        user: Project.t() | Organization.t() | nil
    ):: any
    def create!(requests, options \\ []) do
        Rest.post!(
            resource(),
            requests,
            options
        )
    end

    @doc """
    Receive a single PixRequest struct previously created in the Stark Infra API by its id

    ## Parameters (required):
        - `:id` [string]: struct unique id. ex: "5656565656565656"

    ## Options:
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - PixRequest struct with updated attributes
    """
    @spec get(
        id: binary,
        user: Project.t() | Organization.t() | nil
    )::
        {:ok, PixRequest.t()} |
        {:error, [error: Error.t()]}
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
        user: Project.t() | Organization.t() | nil
    ):: any
    def get!(id, options \\ []) do
        Rest.get_id!(
            resource(),
            id,
            options
        )
    end

    @doc """
    Receive a stream of PixRequest structs previously created in the Stark Infra API

    ## Options:
        - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
        - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020, 3, 10]
        - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020, 3, 10]
        - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: “created”, “processing”, “success”, “failed”
        - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
        - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
        - `:end_to_end_ids` [list of strings, default nil]: central bank's unique transaction IDs. ex: ["E79457883202101262140HHX553UPqeq", "E79457883202101262140HHX553UPxzx"]
        - `:external_ids` [list of strings, default nil]: url safe strings that must be unique among all your PixRequests. Duplicated external IDs will cause failures. By default, this parameter will block any PixRequests that repeats amount and receiver information on the same date. ex: ["my-internal-id-123456", "my-internal-id-654321"]
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - stream of PixRequest structs with updated attributes
    """
    @spec query(
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        status: [binary],
        tags: [binary],
        ids: [binary],
        end_to_end_ids: [binary],
        external_ids: [binary],
        user: Project.t() | Organization.t() | nil
    )::
        {:ok, [PixRequest.t()]} |
        {:error, [error: Error.t()]}
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
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        status: [binary],
        tags: [binary],
        ids: [binary],
        end_to_end_ids: [binary],
        external_ids: [binary],
        user: Project.t() | Organization.t() | nil
    ):: any
    def query!(options \\ []) do
        Rest.get_list!(
            resource(),
            options
        )
    end

    @doc """
    Receive a list of up to 100 PixRequest structs previously created in the Stark Infra API and the cursor to the next page.
    Use this function instead of query if you want to manually page your requests.

    ## Options:
        - `:cursor` [string, default nil]: cursor returned on the previous page function call
        - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
        - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020, 3, 10]
        - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020, 3, 10]
        - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: “created”, “processing”, “success”, “failed”
        - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
        - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
        - `:end_to_end_ids` [list of strings, default nil]: central bank's unique transaction IDs. ex: ["E79457883202101262140HHX553UPqeq", "E79457883202101262140HHX553UPxzx"]
        - `:external_ids` [list of strings, default nil]: url safe strings that must be unique among all your PixRequests. Duplicated external IDs will cause failures. By default, this parameter will block any PixRequests that repeats amount and receiver information on the same date. ex: ["my-internal-id-123456", "my-internal-id-654321"]
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

        ## Return:
        - list of PixRequest structs with updated attributes
        - cursor to retrieve the next page of PixRequest structs
    """
    @spec page(
        cursor: binary,
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        status: [binary],
        tags: [binary],
        ids: [binary],
        end_to_end_ids: [binary],
        external_ids: [binary],
        user: Project.t() | Organization.t() | nil
    ) ::
        {:ok, {[PixRequest.t()], cursor: binary}} |
        {:error, [error: Error.t()]}
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
        cursor: binary,
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        status: [binary],
        tags: [binary],
        ids: [binary],
        end_to_end_ids: [binary],
        external_ids: [binary],
        user: Project.t() | Organization.t() | nil
    ) :: any
    def page!(options \\ []) do
        Rest.get_page!(
            resource(),
            options
        )
    end

    @doc """
    Create a single PixRequest struct from a content string received from a handler listening at the request url.
    If the provided digital signature does not check out with the StarkInfra public key, a
    starkinfra.error.InvalidSignatureError will be raised.

    ## Parameters (required):
        - `:content` [string]: response content from request received at user endpoint (not parsed)
        - `:signature` [string]: base-64 digital signature received at response header "Digital-Signature"

    ## Options:
        - `cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - Parsed PixRequest object
    """
    @spec parse(
        content: binary,
        signature: binary,
        cache_pid: PID,
        user: Project.t() | Organization.t()
    )::
        {:ok, PixRequest.t()} |
        {:error, [error: Error.t()]}
    def parse(options) do
        %{content: content, signature: signature, cache_pid: cache_pid, user: user} =
        Enum.into(
            options |> Check.enforced_keys([:content, :signature]),
            %{cache_pid: nil, user: nil}
        )
        Parse.parse_and_verify(
            content: content,
            signature: signature,
            cache_pid: cache_pid,
            key: nil,
            resource_maker:  &resource_maker/1,
            user: user
        )
    end

    @doc """
    Same as parse(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec parse!(
        content: binary,
        signature: binary,
        cache_pid: PID,
        user: Project.t() | Organization.t()
    ) :: any
    def parse!(options \\ []) do
        %{content: content, signature: signature, cache_pid: cache_pid, user: user} =
            Enum.into(
                options |> Check.enforced_keys([:content, :signature]),
                %{cache_pid: nil, user: nil}
            )
        Parse.parse_and_verify!(
            content: content,
            signature: signature,
            cache_pid: cache_pid,
            key: nil,
            resource_maker:  &resource_maker/1,
            user: user
        )
    end

    @doc false
    def resource() do
        {
            "PixRequest",
            &resource_maker/1
        }
    end

    @doc false
    def resource_maker(json) do
        %PixRequest{
            amount: json[:amount],
            external_id: json[:external_id],
            sender_name: json[:sender_name],
            sender_tax_id: json[:sender_tax_id],
            sender_branch_code: json[:sender_branch_code],
            sender_account_number: json[:sender_account_number],
            sender_account_type: json[:sender_account_type],
            receiver_name: json[:receiver_name],
            receiver_tax_id: json[:receiver_tax_id],
            receiver_bank_code: json[:receiver_bank_code],
            receiver_account_number: json[:receiver_account_number],
            receiver_branch_code: json[:receiver_branch_code],
            receiver_account_type: json[:receiver_account_type],
            end_to_end_id: json[:end_to_end_id],
            receiver_key_id: json[:receiver_key_id],
            description: json[:description],
            reconciliation_id: json[:reconciliation_id],
            initiator_tax_id: json[:initiator_tax_id],
            cash_amount: json[:cash_amount],
            cashier_bank_code: json[:cashier_bank_code],
            cashier_type: json[:cashier_type],
            tags: json[:tags],
            method: json[:method],
            id: json[:id],
            fee: json[:fee],
            status: json[:status],
            flow: json[:flow],
            sender_bank_code: json[:sender_bank_code],
            created: json[:created] |> Check.datetime(),
            updated: json[:updated] |> Check.datetime()
        }
    end
end
