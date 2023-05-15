defmodule StarkInfra.IssuingRestock do
  alias __MODULE__, as: IssuingRestock
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
    # IssuingRestock object
  """

  @doc """
  The IssuingRestock object displays the information of the restock orders created in your Workspace.
  This resource place a restock order for a specific IssuingStock object.

  ## Parameters (required):
    - `:count` [binary]: number of restocks to be restocked. ex: 100
    - `:stock_id` [binary]: IssuingStock unique id ex: "5136459887542272"

  ## Parameters (optional):
    - `:tags` [list of binaries, default []]: list of strings for tagging. ex: ["card", "corporate"]

    ## Attributes (return-only):
    - `:id` [binary]: unique id returned when IssuingRestock is created. ex: "5656565656565656"
    - `:status` [binary]: current IssuingCard status. ex: "approved", "canceled", "denied", "confirmed", "voided"
    - `:updated` [DateTime]: latest update datetime for the IssuingRestock. ex: ~U[2020-03-10 10:30:0:0]
    - `:created` [DateTime]: creation datetime for the IssuingRestock. ex: ~U[2020-03-10 10:30:0:0]
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
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of IssuingRestock objects for creation in the Stark Infra API

  ## Parameters (required):
    - `:restocks` [list of IssuingRestock objects]: list of IssuingRestock objects to be created in the API

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingRestock objects with updated attributes
  """
  @spec create(
    [IssuingRestock.t() | map()],
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
    [IssuingRestock.t() | map()],
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
  Receive a single IssuingRestock object previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingRestock object that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IssuingRestock.t()} |
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
  Receive a stream of IssuingRestock objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "confirmed"]
    - `:stock_ids` [list of binaries, default nil]: list of stock_ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["card", "corporate"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingRestock objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    stock_ids: [binary],
    tags: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IssuingRestock.t()]}} |
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
  @spec page!(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    stock_ids: [binary],
    tags: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 IssuingRestock objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "confirmed"]
    - `:stock_ids` [list of binaries, default nil]: list of stock_ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["card", "corporate"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingRestock objects with updated attributes
    - cursor to retrieve the next page of IssuingRestock objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    stock_ids: [binary],
    tags: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IssuingRestock.t()]}} |
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
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    stock_ids: [binary],
    tags: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

    @spec resource ::
            {<<_::120>>, (nil | maybe_improper_list | map -> StarkInfra.IssuingRestock.t())}
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
      created: json[:created],
      updated: json[:updated]
    }
  end
end
