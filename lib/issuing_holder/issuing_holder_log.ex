defmodule StarkInfra.IssuingHolder.Log do
    alias __MODULE__, as: Log
    alias StarkInfra.Utils.Rest
    alias StarkInfra.Utils.Check
    alias StarkInfra.User.Project
    alias StarkInfra.User.Organization
    alias StarkInfra.Error

    @moduledoc """
        Groups IssuingHolder.Log related functions
    """

    @doc """
    Every time an IssuingHolder entity is updated, a corresponding IssuingHolder.Log
    is generated for the entity. This log is never generated by the
    user, but it can be retrieved to check additional information
    on the IssuingHolder.

    ## Attributes:
        - `:id` [string]: unique id returned when the log is created. ex: "5656565656565656"
        - `:holder` [IssuingHolder]: IssuingHolder entity to which the log refers to.
        - `:type` [string]: type of the IssuingHolder event which triggered the log creation. ex: "blocked", "canceled", "created", "unblocked", "updated"
        - `:created` [DateTime]: creation datetime for the log. ex: ~U[2020-03-10 10:30:0:0]
    """
    @enforce_keys [
        :id,
        :holder,
        :type,
        :created
    ]
    defstruct [
        :id,
        :holder,
        :type,
        :created
    ]

    @type t() :: %__MODULE__{}

    @doc """
    Receive a single IssuingHolder.Log struct previously created by the Stark Infra API by its id.

    ## Parameters (required):
        - `:id` [string]: struct unique id. ex: "5656565656565656"

    ## Options:
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - IssuingHolder.Log struct with updated attributes
    """
    @spec get(
        id: binary,
        user: Project.t() | Organization.t() | nil
    ) ::
        { :ok, Log.t() } |
        { :error, [Error.t()] }
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
    ) :: any
    def get!(id, options \\ []) do
        Rest.get_id!(
            resource(),
            id,
            options
        )
    end

    @doc """
    Receive a stream of IssuingHolder.Log structs previously created in the Stark Infra API

    ## Options:
        - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
        - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
        - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
        - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
        - `:types` [list of strings, default nil]: filter for log event types. ex: ["created", "blocked"]
        - `:holder_ids` [list of strings, default nil]: list of IssuingHolder ids to filter logs. ex: ["5656565656565656", "4545454545454545"]
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - stream of IssuingHolder.Log structs with updated attributes
    """
    @spec query(
        ids: [binary],
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        types: [binary],
        holder_ids: [binary],
        user: Project.t() | Organization.t() | nil
    ) ::
        { :ok, {binary, [Log.t()]} } |
        { :error, [Error.t()] }
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
        ids: [binary],
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        types: [binary],
        holder_ids: [binary],
        user: Project.t() | Organization.t() | nil
    ) :: any
    def query!(options \\ []) do
        Rest.get_list!(
            resource(),
            options
        )
    end

    @doc """
    Receive a list of up to 100 IssuingHolder.Log structs previously created in the Stark Infra API and the cursor to the next page.
    Use this function instead of query if you want to manually page your requests.

    ## Options:
        - `:cursor` [string, default nil]: cursor returned on the previous page function call
        - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
        - `:limit` [integer, default 100]: maximum number of structs to be retrieved. It must be an integer between 1 and 100. ex: 50
        - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
        - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
        - `:types` [list of strings, default nil]: filter for log event types. ex: ["created", "blocked"]
        - `:holder_ids` [list of strings, default nil]: list of IssuingHolder ids to filter logs. ex: ["5656565656565656", "4545454545454545"]
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - list of IssuingHolder.Log structs with updated attributes
        - cursor to retrieve the next page of IssuingHolder.Log structs
    """
    @spec page(
        cursor: binary,
        ids: [binary],
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        types: [binary],
        holder_ids: [binary],
        user: Project.t() | Organization.t() | nil
    ) ::
        { :ok, {binary, [Log.t()]} } |
        { :error, [Error.t()] }
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
        ids: [binary],
        limit: integer,
        after: Date.t() | binary,
        before: Date.t() | binary,
        types: [binary],
        holder_ids: [binary],
        user: Project.t() | Organization.t() | nil
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
            "IssuingHolderLog",
            &resource_maker/1
        }
    end

    @doc false
    def resource_maker(json) do
        %Log{
            id: json[:id],
            holder: json[:holder],
            type: json[:type],
            created: json[:created] |> Check.datetime(),
        }
    end
end
