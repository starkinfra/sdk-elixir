defmodule StarkInfra.PixStatement do
    alias __MODULE__, as: PixStatement
    alias StarkInfra.Utils.Rest
    alias StarkInfra.Utils.Check
    alias StarkInfra.User.Project
    alias StarkInfra.User.Organization
    alias StarkInfra.Error

    @moduledoc """
    Groups PixStatement related functions
    """

    @doc """
    The PixStatement struct stores information about all the transactions that
    happened on a specific day at your settlment account according to the Central Bank.
    It must be created by the user before it can be accessed.
    This feature is only available for direct participants.
    When you initialize a PixStatement, the entity will not be automatically
    created in the Stark Infra API. The 'create' function sends the structs
    to the Stark Infra API and returns the created struct.

    ## Parameters (required):
        - `:after` [Date]: transactions that happened at this date are stored in the PixStatement, must be the same as before. ex: ~D[2020, 3, 10]
        - `:before` [Date]: transactions that happened at this date are stored in the PixStatement, must be the same as after. ex: ~D[2020, 3, 10]
        - `:type` [string]: types of entities to include in statement. Options: ["interchange", "interchangeTotal", "transaction"]

    ## Attributes (return-only):
        - `:id` [string]: unique id returned when the PixStatement is created. ex: "5656565656565656"
        - `:status` [string]: current PixStatement status. ex: ["success", "failed"]
        - `:transaction_count` [integer]: number of transactions that happened during the day that the PixStatement was requested. ex: 11
        - `:created` [DateTime]: creation datetime for the PixStatement. ex: ~U[2020-03-10 10:30:0:0]
        - `:updated` [DateTime]: latest update datetime for the PixStatement. ex: ~U[2020-03-10 10:30:0:0]
    """
    @enforce_keys [
        :after,
        :before,
        :type
    ]
    defstruct [
        :after,
        :before,
        :type,
        :id,
        :status,
        :transaction_count,
        :created,
        :updated
    ]

    @type t() :: %__MODULE__{}

    @doc """
    Create a PixStatement linked to your Workspace in the Stark Infra API

    ## Options:
        - `:statement` [PixStatement struct]: PixStatement struct to be created in the API.

    ## Options:
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - PixStatement struct with updated attributes.
    """
    @spec create(
        PixStatement.t() | map(),
        user: Project.t() | Organization.t() | nil
    ) ::
        {:ok, PixStatement.t()} |
        {:error, [error: Error.t()]}
    def create(keys, options \\ []) do
        Rest.post_single(
            resource(),
            keys,
            options
        )
    end

    @doc """
    Same as create(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec create!(
        PixStatement.t() | map(),
        user: Project.t() | Organization.t() | nil
    ) ::
        {:ok, PixStatement.t()} |
        {:error, [error: Error.t()]}
    def create!(keys, options \\ []) do
        Rest.post_single!(
            resource(),
            keys,
            options
        )
    end

    @doc """
    Retrieve the PixStatement struct linked to your Workspace in the Stark Infra API by its id.

    ## Parameters (required):
        - `:id` [string]: struct unique id. ex: "5656565656565656"

    ## Options:
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - PixStatement struct that corresponds to the given id.
    """
    @spec get(
        id: binary,
        user: Project.t() | Organization.t() | nil
    ) ::
        {:ok, PixStatement.t()} |
        {:error, [error: Error.t()]}
    def get(id, options \\ []) do
        Rest.get_id(resource(), id, options)
    end

    @doc """
    Same as get(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec get!(
        id: binary,
        user: Project.t() | Organization.t() | nil
    ) ::
        {:ok, PixStatement.t()} |
        {:error, [error: Error.t()]}
    def get!(id, options \\ []) do
        Rest.get_id!(resource(), id, options)
    end

    @doc """
    Receive a stream of PixStatements structs previously created in the Stark Infra API

    ## Options:
        - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
        - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - stream of PixStatement structs with updated attributes
    """
    @spec query(
        limit: integer,
        ids: [binary],
        user: Project.t() | Organization.t() | nil
    ) ::
        ({:cont, [PixStatement.t()]} |
        {:error, [Error.t()]})
    def query(options \\ []) do
        Rest.get_list(resource(), options)
    end

    @doc """
    Same as query(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec query!(
        limit: integer,
        ids: [binary],
        user: Project.t() | Organization.t() | nil
    ) ::
        ({:cont, [PixStatement.t()]} |
        {:error, [Error.t()]})
    def query!(options \\ []) do
        Rest.get_list!(resource(), options)
    end

    @doc """
    Receive a list of up to 100 PixStatements structs previously created in the Stark Infra API

    ## Options:
        - `:cursor` [string, default nil]: cursor returned on the previous page function call
        - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
        - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - list of PixStatement structs with updated attributes
        - cursor to retrieve the next page of PixStatement structs
    """
    @spec page(
        cursor: binary,
        limit: integer,
        ids: [binary],
        user: Project.t() | Organization.t() | nil
    ) ::
        ({:cont, [PixStatement.t()]} |
        {:error, [Error.t()]})
    def page(options \\ []) do
        Rest.get_page(resource(), options)
    end

    @doc """
    Same as page(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec page!(
        cursor: binary,
        limit: integer,
        ids: [binary],
        user: Project.t() | Organization.t() | nil
    ) ::
        ({:cont, [PixStatement.t()]} |
        {:error, [Error.t()]})
    def page!(options \\ []) do
        Rest.get_page!(resource(), options)
    end

    @doc """
    Retrieve a specific PixStatement by its ID in a .csv file.

    ## Parameters (required):
        - `:id` [string]: struct unique id. ex: "5656565656565656"

    ## Options:
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - .zip file containing a PixStatement in .csv format
    """
    @spec csv(
        id: binary,
        user: Project.t() | Organization.t() | nil
    ) ::
        {:ok, binary} |
        {:error, [error: Error.t()]}
    def csv(id, options \\ []) do
        Rest.get_content(resource(), id, "csv", options, options[:user])
    end

    @doc """
    Same as csv(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec csv!(
        id: binary,
        user: Project.t() | Organization.t() | nil
    ) ::
        {:ok, binary} |
        {:error, [error: Error.t()]}
    def csv!(id, options \\ []) do
        Rest.get_content!(resource(), id, "csv", options, options[:user])
    end

    @doc false
    def resource() do
        {
            "PixStatement",
            &resource_maker/1
        }
    end

    @doc false
    def resource_maker(json) do
        %PixStatement{
            after: json[:after],
            before: json[:before],
            type: json[:type],
            id: json[:id],
            status: json[:status],
            transaction_count: json[:transaction_count],
            created:  json[:created] |> Check.datetime(),
            updated:  json[:updated] |> Check.datetime()
        }
    end
end
