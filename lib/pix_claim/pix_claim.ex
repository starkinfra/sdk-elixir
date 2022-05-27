defmodule StarkInfra.PixClaim do
    alias __MODULE__, as: PixClaim
    alias StarkInfra.Utils.Rest
    alias StarkInfra.Utils.Check
    alias StarkInfra.User.Project
    alias StarkInfra.User.Organization
    alias StarkInfra.Error

    @moduledoc """
    Groups PixClaim related functions
    """

    @doc """
    PixClaims intend to transfer a PixKey from one account to another.
    When you initialize a PixClaim, the entity will not be automatically
    created in the Stark Infra API. The 'create' function sends the structs
    to the Stark Infra API and returns the created struct.

    ## Parameters (required):
        - `:account_created` [Date, DateTime or string]: opening Date or DateTime for the account claiming the PixKey. ex: "2022-01-01".
        - `:account_number` [string]: number of the account claiming the PixKey. ex: "76543".
        - `:account_type` [string]: type of the account claiming the PixKey. Options: "checking", "savings", "salary" or "payment".
        - `:branch_code` [string]: branch code of the account claiming the PixKey. ex: 1234".
        - `:name` [string]: holder's name of the account claiming the PixKey. ex: "Jamie Lannister".
        - `:tax_id` [string]: holder's taxId of the account claiming the PixKey (CPF/CNPJ). ex: "012.345.678-90".
        - `:key_id` [string]: id of the registered Pix Key to be claimed. Allowed keyTypes are CPF, CNPJ, phone number or email. ex: "+5511989898989".

    ## Attributes (return-only):
        - `:id` [string]: unique id returned when the PixClaim is created. ex: "5656565656565656"
        - `:status` [string]: current PixClaim status. Options: "created", "failed", "delivered", "confirmed", "success", "canceled"
        - `:type` [string]: type of Pix Claim. Options: "ownership", "portability".
        - `:key_type` [string]: keyType of the claimed PixKey. Options: "CPF", "CNPJ", "phone" or "email"
        - `:agent` [string]: Options: "claimer" if you requested the PixClaim or "claimed" if you received a PixClaim request.
        - `:bank_code` [string]: bank_code of the account linked to the PixKey being claimed. ex: "20018183".
        - `:claimed_bank_code` [string]: bank_code of the account donating the PixKey. ex: "20018183".
        - `:created` [DateTime]: creation DateTime for the PixClaim. ex: ~U[2020-3-10 10:30:0:0]
        - `:updated` [DateTime]: update DateTime for the PixClaim. ex: ~U[2020-3-10 10:30:0:0]
    """
    @enforce_keys [
        :account_created,
        :account_number,
        :account_type,
        :branch_code,
        :name,
        :tax_id,
        :key_id
    ]
    defstruct [
        :account_created,
        :account_number,
        :account_type,
        :branch_code,
        :name,
        :tax_id,
        :key_id,
        :id,
        :status,
        :type,
        :key_type,
        :agent,
        :bank_code,
        :claimed_bank_code,
        :created,
        :updated
    ]

    @type t() :: %__MODULE__{}

    @doc """
    Create a PixClaim to request the transfer of a PixKey to an account
    hosted at other Pix participants in the Stark Infra API.

    ## Parameters (required):
        - `:claim` [PixClaim struct]: PixClaim struct to be created in the API.

    ## Options:
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - PixClaim struct with updated attributes.
    """
    @spec create(
        PixClaim.t() | map(),
        user: Project.t() | Organization.t() | nil
    ) ::
        {:ok, PixClaim.t()} |
        {:error, [error: Error.t()]}
    def create(keys, options \\ []) do
        Rest.post_single(
            resource(),
            keys,
            options
        )
    end

    @doc """
    Same as create, but it will unwrap the error tuple and raise in case of error.
    """
    @spec create!(PixClaim.t() | map(), user: Project.t() | Organization.t() | nil) :: any
    def create!(keys, options \\ []) do
        Rest.post_single!(
            resource(),
            keys,
            options
        )
    end

    @doc """
    Retrieve a PixClaim struct linked to your Workspace in the Stark Infra API by its id.

    ## Parameters (required):
        - `:id` [string]: struct unique id. ex: "5656565656565656"

    ## Options:
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - PixClaim struct that corresponds to the given id.
    """
    @spec get(
        id: binary,
        user: Project.t() | Organization.t() | nil
    ) ::
        {:ok, PixClaim.t()} |
        {:error, [error: Error.t()]}
    def get(id, options \\ []) do
        Rest.get_id(
            resource(),
            id,
            options
        )
    end

    @doc """
    Same as get, but it will unwrap the error tuple and raise in case of error.
    """
    @spec get!(
        id: binary,
        user: Project.t() | Organization.t() | nil
    ) :: any
    def get!(id, options \\ []) do
        Rest.get_id!(
            resource(),
            id,
            options
        )
    end

    @doc """
    Receive a stream of PixClaims structs previously created in the Stark Infra API

    ## Options:
        - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
        - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
        - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
        - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: "created", "failed", "delivered", "confirmed", "success", "canceled".
        - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
        - `:type` [strings, default nil]: filter for the type of retrieved PixClaims. Options: "ownership" or "portability".
        - `:agent` [string, default nil]: filter for the agent of retrieved PixClaims. Options: "claimer" or "claimed".
        - `:key_type` [string, default nil]: filter for the PixKey type of retrieved PixClaims. Options: "cpf", "cnpj", "phone", "email", "evp".
        - `:key_id` [string, default nil]: filter PixClaims linked to a specific PixKey id. Example: "+5511989898989".
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - stream of PixClaim structs with updated attributes
    """
    @spec query(
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        status: binary,
        ids: [binary],
        type: binary,
        agent: binary,
        key_type: binary,
        key_id: binary,
        user: Project.t() | Organization.t() | nil
    ) ::
        {:ok, [PixClaim.t()]} | {:error, [error: Error.t()]}
    def query(options \\ []) do
        Rest.get_list(
            resource(),
            options
        )
    end

    @doc """
    Same as query, but it will unwrap the error tuple and raise in case of error.
    """
    @spec query!(
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        status: binary,
        ids: [binary],
        type: binary,
        agent: binary,
        key_type: binary,
        key_id: binary,
        user: Project.t() | Organization.t() | nil
    ) :: any
    def query!(options \\ []) do
        Rest.get_list!(
            resource(),
            options
        )
    end

    @doc """
    Receive a list of up to 100 PixClaims structs previously created in the Stark Infra API and the cursor to the next page.
    Use this function instead of query if you want to manually page your requests.

    ## Options:
        - `:cursor` [string, default nil]: cursor returned on the previous page function call.
        - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
        - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020, 3, 10]
        - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020, 3, 10]
        - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: "created", "failed", "delivered", "confirmed", "success", "canceled"
        - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
        - `:type` [strings, default nil]: filter for the type of retrieved PixClaims. Options: "ownership" or "portability".
        - `:agent` [string, default nil]: filter for the agent of retrieved PixClaims. Options: "claimer" or "claimed".
        - `:key_type` [string, default nil]: filter for the PixKey type of retrieved PixClaims. Options: "cpf", "cnpj", "phone", "email", "evp".
        - `:key_id` [string, default nil]: filter PixClaims linked to a specific PixKey id. Example: "+5511989898989".
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - cursor to retrieve the next page of PixClaim structs
        - stream of PixClaim structs with updated attributes
    """
    @spec page(
        cursor: binary,
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        status: binary,
        ids: [binary],
        type: binary,
        agent: binary,
        key_type: binary,
        key_id: binary,
        user: Project.t() | Organization.t() | nil
    ) ::
        {:ok, {binary, [PixClaim.t()]}} |
        {:error, [error: Error.t()]}
    def page(options \\ []) do
        Rest.get_page(
            resource(),
            options
        )
    end

    @doc """
    Same as page, but it will unwrap the error tuple and raise in case of error.
    """
    @spec page!(
        cursor: binary,
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        status: binary,
        ids: [binary],
        type: binary,
        agent: binary,
        key_type: binary,
        key_id: binary,
        user: Project.t() | Organization.t() | nil
    ) :: any
    def page!(options \\ []) do
        Rest.get_page!(
            resource(),
            options
        )
    end

    @doc """
    Update a PixClaim parameters by passing id.

    ## Parameters (required):
        - `:id` [string]: PixClaim id. ex: '5656565656565656'
        - `:status` [string]: patched status for Pix Claim. Options: "confirmed" and "canceled"

    ## Options:
        - `:reason` [string, default: "userRequested"]: reason why the PixClaim is being patched. Options: "fraud", "userRequested".
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - PixClaim with updated attributes
    """
    @spec update(
        binary,
        status: binary,
        reason: binary,
        user: Project.t() | Organization.t() | nil
    ) ::
        {:ok, PixClaim.t()} |
        {:error, [error: Error.t()]}
    def update(id, status, options \\ %{}) do
        options = Map.put(options, "status", status)
        Rest.patch_id(
            resource(),
            id,
            options
        )
    end

    @doc """
    Same as update, but it will unwrap the error tuple and raise in case of error.
    """
    @spec update!(
        binary,
        status: binary,
        reason: binary,
        user: Project.t() | Organization.t() | nil
    ) :: any
    def update!(id, status, options \\ %{}) do
        options = Map.put(options, "status", status)
        Rest.patch_id!(
            resource(),
            id,
            options
        )
    end

    @doc false
    def resource() do
        {
            "PixClaim",
            &resource_maker/1
        }
    end

    @doc false
    def resource_maker(json) do
        %PixClaim{
            account_created: json[:account_created] |> Check.datetime(),
            account_number: json[:account_number],
            account_type: json[:account_type],
            branch_code: json[:branch_code],
            name: json[:name],
            tax_id: json[:tax_id],
            key_id: json[:key_id],
            id: json[:id],
            status: json[:status],
            type: json[:type],
            key_type: json[:key_type],
            agent: json[:agent],
            bank_code: json[:bank_code],
            claimed_bank_code: json[:claimed_bank_code],
            created:  json[:created] |> Check.datetime(),
            updated:  json[:updated] |> Check.datetime()
        }
    end
end
