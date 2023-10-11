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
  The PixStatement object stores information about all the transactions that
  happened on a specific day at your settlement account according to the Central Bank.
  It must be created by the user before it can be accessed.
  This feature is only available for direct participants.

  When you initialize a PixStatement, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the objects
  to the Stark Infra API and returns the created object.

  ## Parameters (required):
    - `:after` [Date]: transactions that happened at this date are stored in the PixStatement, must be the same as before. ex: ~D[2020, 3, 10]
    - `:before` [Date]: transactions that happened at this date are stored in the PixStatement, must be the same as after. ex: ~D[2020, 3, 10]
    - `:type` [binary]: types of entities to include in statement. ex: ["interchange", "interchangeTotal", "transaction"]

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the PixStatement is created. ex: "5656565656565656"
    - `:status` [binary]: current PixStatement status. ex: ["success", "failed"]
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

  ## Parameters (optional):
    - `:statement` [PixStatement object]: PixStatement object to be created in the API.

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixStatement object with updated attributes.
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
  Retrieve the PixStatement object linked to your Workspace in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixStatement object that corresponds to the given id.
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
  Receive a stream of PixStatement objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixStatement objects with updated attributes
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
  Receive a list of up to 100 PixStatement objects previously created in the Stark Infra API
  Use this function instead of query if you want to manually page your statements.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixStatement objects with updated attributes
    - cursor to retrieve the next page of PixStatement objects
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
  Retrieve a specific PixStatement by its id in a .csv file.

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

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
