defmodule StarkInfra.PixInfraction do
    alias __MODULE__, as: PixInfraction
    alias StarkInfra.Utils.Rest
    alias StarkInfra.Utils.Check
    alias StarkInfra.User.Project
    alias StarkInfra.User.Organization
    alias StarkInfra.Error

    @moduledoc """
    Groups PixInfraction related functions
    """

    @doc """
    PixInfraction are used to report transactions that are suspected of
    fraud, to request a refund or to reverse a refund.
    When you initialize a PixInfraction, the entity will not be automatically
    created in the Stark Infra API. The 'create' function sends the objects
    to the Stark Infra API and returns the created struct.

    ## Parameters (required):
        - `:reference_id` [string]: end_to_end_id or return_id of the transaction being reported. ex: "E20018183202201201450u34sDGd19lz"
        - `:type` [string]: type of infraction report. Options: "fraud", "reversal", "reversalChargeback"

    ## Parameters (optional):
        - `:description` [string, default nil]: description for any details that can help with the infraction investigation.

    ## Attributes (return-only):
        - id [string]: unique id returned when the PixInfraction is created. ex: "5656565656565656"
        - credited_bank_code [string]: bank_code of the credited Pix participant in the reported transaction. ex: "20018183"
        - debited_bank_code [string]: bank_code of the debited Pix participant in the reported transaction. ex: "20018183"
        - agent [string]: Options: "reporter" if you created the PixInfraction, "reported" if you received the PixInfraction.
        - analysis [string]: analysis that led to the result.
        - bacen_id [string]: central bank's unique UUID that identifies the infraction report.
        - reported_by [string]: agent that reported the PixInfraction. Options: "debited", "credited".
        - result [string]: result after the analysis of the PixInfraction by the receiving party. Options: "agreed", "disagreed"
        - status [string]: current PixInfraction status. Options: "created", "failed", "delivered", "closed", "canceled".
        - created [DateTime]: creation datetime for the PixInfraction. ex: ~U[2020-3-10 10:30:0:0]
        - updated [DateTime]: latest update datetime for the PixInfraction. ex: ~U[2020-3-10 10:30:0:0]
    """
    @enforce_keys [
        :reference_id,
        :type
    ]
    defstruct [
        :reference_id,
        :type,
        :description,
        :id,
        :credited_bank_code,
        :debited_bank_code,
        :agent,
        :analysis,
        :bacen_id,
        :reported_by,
        :result,
        :status,
        :created,
        :updated
    ]

    @type t() :: %__MODULE__{}

    @doc """
    Create PixInfractions in the Stark Infra API

    ## Parameters (required):
        - `:infractions` [list of PixInfraction]: list of PixInfraction structs to be created in the API.

    ## Options:
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - list of PixInfraction structs with updated attributes
    """
    @spec create(
        [PixInfraction.t() | map],
        user: Organization.t() | Project.t() | nil
    ) ::
        {:ok, [PixInfraction.t() | map]} |
        {:error, Error.t()}
    def create(infractions, options \\ []) do
        Rest.post(
            resource(),
            infractions,
            options
        )
    end

    @doc """
    Same as create(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec create!(
        [PixInfraction.t() | map],
        user: Organization.t() | Project.t() | nil
    ) :: any
    def create!(infractions, options \\ []) do
        Rest.post!(
            resource(),
            infractions,
            options
        )
    end

    @doc """
    Retrieve the PixInfraction struct linked to your Workspace in the Stark Infra API using its id.

    ## Parameters (required):
        - `:id` [string]: struct unique id. ex: "5656565656565656".

    ## Options:
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - PixInfraction struct that corresponds to the given id.
    """
    @spec get(
        id: binary,
        user: Organization.t() | Project.t() | nil
    ) ::
        {:ok, PixInfraction.t()} |
        {:error, Error.t()}
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
    Receive a stream of PixInfractions structs previously created in the Stark Infra API

    ## Options:
        - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
        - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
        - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
        - `:status` [list of strings, default nil]: filter for status of retrieved objects. ex: ["created", "failed", "delivered", "closed", "canceled"]
        - `:ids` [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
        - `:type` [list of strings, default nil]: filter for the type of retrieved PixInfractions. Options: "fraud", "reversal", "reversalChargeback"
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - stream of PixInfraction structs with updated attributes
    """
    @spec query(
        limit: integer | nil,
        after: Date.t() | binary | nil,
        before: Date.t() | binary | nil,
        status: [binary] | nil,
        ids: [binary] | nil,
        type: [binary] | nil,
        user: Organization.t() | Project.t() | nil
    ) ::
        ({:cont, {:ok, [PixInfraction.t() | map]}} |
        {:error, [Error.t()]} |
        {:halt, any} |
        {:suspend, any},
        any ->  any)
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
        ids: [binary] | nil,
        type: [binary] | nil,
        user: Organization.t() | Project.t() | nil
    ) :: any
    def query!(options \\ []) do
        Rest.get_list!(
            resource(),
            options
        )
    end

    @doc """
    Receive a list of up to 100 PixInfractions structs previously created in the Stark Infra API and the cursor to the next page.
    Use this function instead of query if you want to manually page your requests.

    ## Options:
        - `:cursor` [string, default nil]: cursor returned on the previous page function call.
        - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
        - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
        - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
        - `:status` [list of strings, default nil]: filter for status of retrieved objects. ex: ["created", "failed", "delivered", "closed", "canceled"]
        - `:ids` [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
        - `:type` [list of strings, default nil]: filter for the type of retrieved PixInfractions. Options: "fraud", "reversal", "reversalChargeback"
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - list of PixInfraction structs with updated attributes and cursor to retrieve the next page of PixInfraction objects
    """
    @spec page(
        cursor: binary | nil,
        limit: integer | nil,
        after: Date.t() | binary | nil,
        before: Date.t() | binary | nil,
        status: [binary] | nil,
        ids: [binary] | nil,
        type: [binary] | nil,
        user: Organization.t() | Project.t() | nil
    ) ::
        {:ok, {binary, [PixInfraction.t() | map]}} |
        {:error, Error.t()}
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
        ids: [binary] | nil,
        type: [binary] | nil,
        user: Organization.t() | Project.t() | nil
    ) :: any
    def page!(options \\ []) do
        Rest.get_page!(
            resource(),
            options
        )
    end

    @doc """
    Respond to a received PixInfraction.

    ## Parameters (required):
        - `:id` [string]: PixInfraction id. ex: '5656565656565656'
        - `:result` [string]: result after the analysis of the PixInfraction. Options: "agreed", "disagreed"

    ## Options:
        - `:analysis` [string, default nil]: analysis that led to the result.
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - PixInfraction with updated attributes
    """
    @spec update(
        binary,
        result: binary,
        analysis: binary | nil,
        user: Organization.t() | Project.t() | nil
    ) ::
        {:ok, PixInfraction.t()} |
        {:error, Error.t()}
    def update(id, result, parameters \\ %{}) do
        parameters = Map.put(parameters, "result", result)
        Rest.patch_id(
            resource(),
            id,
            parameters
        )
    end

    @doc """
    Same as update(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec update!(
        binary,
        result: binary,
        analysis: binary | nil,
        user: Organization.t() | Project.t() | nil
    ) :: any
    def update!(id, result, parameters \\ %{}) do
        parameters = Map.put(parameters, "result", result)
        Rest.patch_id!(
            resource(),
            id,
            parameters
        )
    end

    @doc """
    Cancel a PixInfraction entity previously created in the Stark Infra API

    ## Parameters (required):
        - `:id` [string]: struct unique id. ex: "5656565656565656"

    ## Options:
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - canceled PixInfraction struct
    """
    @spec cancel(
        id: binary,
        user: Organization.t() | Project.t() | nil
    ) ::
        {:ok, PixInfraction.t()} |
        {:error, Error.t()}
    def cancel(id, options \\ []) do
        Rest.delete_id(
            resource(),
            id,
            options
        )
    end

    @doc """
    Same as cancel(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec cancel!(
        id: binary,
        user: Organization.t() | Project.t() | nil
    ) :: any
    def cancel!(id, options \\ []) do
        Rest.delete_id!(
            resource(),
            id,
            options
        )
    end

    @doc false
    def resource() do
        {
            "PixInfraction",
            &resource_maker/1
        }
    end

    @doc false
    def resource_maker(json) do
        %PixInfraction{
            reference_id: json[:reference_id],
            type: json[:type],
            description: json[:description],
            id: json[:id],
            credited_bank_code: json[:credited_bank_code],
            debited_bank_code: json[:debited_bank_code],
            agent: json[:agent],
            analysis: json[:analysis],
            bacen_id: json[:bacen_id],
            reported_by: json[:reported_by],
            result: json[:result],
            status: json[:status],
            created: json[:created] |> Check.datetime(),
            updated: json[:updated] |> Check.datetime()
        }
    end
end
