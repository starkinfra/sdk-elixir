defmodule StarkInfra.IssuingBin do
    alias __MODULE__, as: IssuingBin
    alias StarkInfra.Utils.Rest
    alias StarkInfra.Utils.Check
    alias StarkInfra.User.Project
    alias StarkInfra.User.Organization
    alias StarkInfra.Error

    @moduledoc """
    Groups IssuingBin related functions
    """

    @doc """
    The IssuingBin struct displays the informations of BINs registered to your Workspace.
    They represent a group of cards that begin with the same numbers (BIN) and offer the same product to end customers.

    ## Attributes (return-only):
        - `:id` [string]: unique BIN number registered within the card network. ex: "53810200"
        - `:network` [string]: card network flag. ex: "mastercard"
        - `:settlement` [string]: settlement type. ex: "credit"
        - `:category` [string]: purchase category. ex: "prepaid"
        - `:client` [string]: client type. ex: "business"
        - `:updated` [DateTime]: latest update DateTime for the IssuingBin. ex: ~U[2020-3-10 10:30:0:0]
        - `:created` [DateTime]: creation datetime for the IssuingBin. ex: ~U[2020-03-10 10:30:0:0]
    """
    @enforce_keys [
        :id,
        :network,
        :settlement,
        :category,
        :client,
        :updated,
        :created
    ]
    defstruct [
        :id,
        :network,
        :settlement,
        :category,
        :client,
        :updated,
        :created
    ]

    @type t() :: %__MODULE__{}

    @doc """
    Receive a stream of IssuingBin structs previously registered in the Stark Infra API

    ## Options:
        - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - stream of IssuingBin structs with updated attributes
    """
    @spec query(
        limit: integer,
        user: Project.t() | Organization.t() | nil
    ) ::
        { :ok, [IssuingBin.t()] } |
        { :error, [error: Error.t()] }
    def query(options \\ []) do
        Rest.get_list(resource(), options)
    end

    @doc """
    Same as query(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec query!(
        limit: integer,
        user: Project.t() | Organization.t() | nil
    ) :: any
    def query!(options \\ []) do
        Rest.get_list!(resource(), options)
    end

    @doc """
    Receive a list of up to 100 IssuingBin structs previously registered in the Stark Infra API and the cursor to the next page.

    ## Options:
        - `:cursor` [string, default nil]: cursor returned on the previous page function call
        - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
        - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
        - list of IssuingBin structs with updated attributes
        - cursor to retrieve the next page of IssuingBin structs
    """
    @spec page(
        cursor: binary,
        limit: integer,
        user: Project.t() | Organization.t() | nil
    ) ::
        { :ok, {binary, [IssuingBin.t()]}} |
        { :error, [error: Error.t()] }
    def page(options \\ []) do
        Rest.get_page(resource(), options)
    end

    @doc """
        \Same as page(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec page!(
        cursor: binary,
        limit: integer,
        user: Project.t() | Organization.t() | nil
    ) :: any
    def page!(options \\ []) do
        Rest.get_page!(resource(), options)
    end

    @doc false
    def resource() do
        {
            "IssuingBin",
            &resource_maker/1
        }
    end

    @doc false
    def resource_maker(json) do
        %IssuingBin{
            id: json[:id],
            network: json[:network],
            settlement: json[:settlement],
            category: json[:category],
            client: json[:client],
            updated: json[:updated] |> Check.datetime(),
            created: json[:created] |> Check.datetime()
        }
    end
end
