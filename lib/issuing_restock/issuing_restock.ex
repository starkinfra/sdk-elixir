defmodule StarkInfra.IssuingRestock do
  alias __MODULE__, as: IssuingRestock
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IssuingRestock related functions
  """

  @doc """
  The IssuingRestock struct displays the information of the restock orders created in your Workspace.
  This resource place a restock order for a specific IssuingStock object.

  ## Parameters (required):
    - `:count` [integer]: number of restocks to be restocked. ex: 100
    - `:stock_id` [string]: IssuingStock unique id ex: "5136459887542272"

  ## Parameters (optional):
    - `:tags` [list of strings, default nil]: list of strings for tagging. ex: ["card", "corporate"]

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when IssuingRestock is created. ex: "5656565656565656"
    - `:status` [string, default nil]: current IssuingRestock status. ex: "created", "processing", "confirmed"
    - `:updated` [DateTime, default nil]: latest update datetime for the IssuingRestock.
    - `:created` [DateTime, default nil]: creation datetime for the IssuingRestock.
  """
  @enforce_keys [
    :count,
    :stock_id
  ]
  defstruct [
    :count,
    :stock_id,
    :tags,
    :id,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of IssuingRestock structs for creation in the Stark Infra API

  ## Parameters (required):
    - `:restocks` [list of IssuingRestock structs]: list of IssuingRestock structs to be created in the API. You can send up to 100 structs in a single request.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingRestock structs with updated attributes
  """
  @spec create(
    [IssuingRestock.t() | map],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [IssuingRestock.t()]} |
    {:error, [Error.t()]}
  def create(restocks, options \\ []) do
    Rest.post(
      resource(),
      restocks,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    [IssuingRestock.t() | map],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(restocks, options \\ []) do
    Rest.post!(
      resource(),
      restocks,
      options
    )
  end

  @doc """
  Receive a single IssuingRestock struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingRestock struct with updated attributes
  """
  @spec get(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, IssuingRestock.t()} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: IssuingRestock.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of IssuingRestock structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil] date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil] date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "processing", "confirmed"]
    - `:stock_ids` [list of strings, default nil]: list of stock_ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["card", "corporate"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingRestock structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    stock_ids: [binary],
    ids: [binary],
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, {:ok, [IssuingRestock.t()]}} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
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
    status: [binary],
    stock_ids: [binary],
    ids: [binary],
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, [IssuingRestock.t()]} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 IssuingRestock structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or string, default nil] date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil] date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "processing", "confirmed"]
    - `:stock_ids` [list of strings, default nil]: list of stock_ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["card", "corporate"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingRestock structs with updated attributes
    - cursor to retrieve the next page of IssuingRestock structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    stock_ids: [binary],
    ids: [binary],
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [IssuingRestock.t()]}} |
    {:error, [Error.t()]}
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
    status: [binary],
    stock_ids: [binary],
    ids: [binary],
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    [IssuingRestock.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "IssuingRestock",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingRestock{
      count: json[:count],
      stock_id: json[:stock_id],
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
