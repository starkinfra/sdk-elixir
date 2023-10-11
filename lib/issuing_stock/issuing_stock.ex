defmodule StarkInfra.IssuingStock do
  alias __MODULE__, as: IssuingStock
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
    # IssuingStock object
  """

  @doc """
  The IssuingStock object displays the information of the restock orders created in your Workspace.
  This resource place a restock order for a specific IssuingStock object.

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when IssuingStock is created. ex: "5656565656565656"
    - `:balance` [integer]: [EXPANDABLE] current stock balance. ex: 1000
    - `:design_id` [binary]: IssuingDesign unique id. ex: "5656565656565656"
    - `:embosser_id` [binary]: Embosser unique id. ex: "5656565656565656"
    - `:updated` [DateTime]: latest update datetime for the IssuingStock. ex: ~U[2020-03-10 10:30:0:0]
    - `:created` [DateTime]: creation datetime for the IssuingStock. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :id,
    :balance,
    :design_id,
    :embosser_id,
    :created,
    :updated,
  ]

  defstruct [
    :id,
    :balance,
    :design_id,
    :embosser_id,
    :created,
    :updated,
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single IssuingStock objects previously created in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:expand` [list of binaries, default nil]: fields to expand information. ex: ["balance"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingStock objects that corresponds to the given id.
  """
  @spec get(
    id: binary,
    expand: [binary] | nil,
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, IssuingStock.t()} |
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
    expand: [binary] | nil,
    user: (Organization.t() | Project.t() | nil)
  ) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(
      resource(),
      id,
      options
    )
  end

  @doc """
  Receive a stream of IssuingStock objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:design_ids` [list of binaries, default nil]: list of stock_ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:embosser_id` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "confirmed"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:expand` [list of binaries, default nil]: fields to expand information. ex: ["balance"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingStock objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    design_ids: [binary],
    embosser_ids: [binary],
    ids: [binary],
    expand: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IssuingStock.t()]}} |
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
    design_ids: [binary],
    embosser_ids: [binary],
    ids: [binary],
    expand: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 IssuingStock objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:design_ids` [list of binaries, default nil]: list of stock_ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:embosser_id` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "confirmed"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:expand` [list of binaries, default nil]: fields to expand information. ex: ["balance"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingStock objects with updated attributes
    - cursor to retrieve the next page of IssuingStock objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    design_ids: [binary],
    embosser_ids: [binary],
    ids: [binary],
    expand: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IssuingStock.t()]}} |
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
            {<<_::120>>, (nil | maybe_improper_list | map -> StarkInfra.IssuingStock.t())}
    @doc false
    def resource() do
      {
        "IssuingStock",
        &resource_maker/1
      }
    end

  @doc false
  def resource_maker(json) do
    %IssuingStock{
      id: json[:id],
      balance: json[:balance],
      design_id: json[:design_id],
      embosser_id: json[:embosser_id],
      created: json[:created],
      updated: json[:updated]
    }
  end
end
