defmodule StarkInfra.IssuingStock do
  alias __MODULE__, as: IssuingStock
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IssuingStock related functions
  """

  @doc """
  The IssuingStock struct represents the current stock of a certain IssuingDesign linked to an Embosser available to your workspace.

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when IssuingStock is created. ex: "5656565656565656"
    - `:balance` [integer, default nil]: [EXPANDABLE] current stock balance. ex: 1000
    - `:design_id` [string, default nil]: IssuingDesign unique id. ex: "5656565656565656"
    - `:embosser_id` [string, default nil]: Embosser unique id. ex: "5656565656565656"
    - `:embosser_name` [string, default nil]: Name of the embosser that holds this stock
    - `:updated` [DateTime, default nil]: latest update datetime for the IssuingStock.
    - `:created` [DateTime, default nil]: creation datetime for the IssuingStock.
  """
  @enforce_keys [
    :id,
    :balance,
    :design_id,
    :embosser_id,
    :embosser_name,
    :created,
    :updated
  ]
  defstruct [
    :id,
    :balance,
    :design_id,
    :embosser_id,
    :embosser_name,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single IssuingStock struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:expand` [list of strings, default nil]: fields to expand information. ex: ["balance"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingStock struct with updated attributes
  """
  @spec get(
    binary,
    expand: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, IssuingStock.t()} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, expand: [binary], user: Project.t() | Organization.t() | nil) :: IssuingStock.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of IssuingStock structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil] date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil] date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:design_ids` [list of strings, default nil]: IssuingDesign unique ids. ex: ["5656565656565656", "4545454545454545"]
    - `:embosser_ids` [list of strings, default nil]: Embosser unique ids. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:expand` [list of strings, default nil]: fields to expand information. ex: ["balance"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingStock structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    design_ids: [binary],
    embosser_ids: [binary],
    ids: [binary],
    expand: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, {:ok, [IssuingStock.t()]}} |
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
    design_ids: [binary],
    embosser_ids: [binary],
    ids: [binary],
    expand: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, [IssuingStock.t()]} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 IssuingStock structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. It must be an integer between 1 and 100. ex: 35
    - `:after` [Date or string, default nil] date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil] date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:design_ids` [list of strings, default nil]: IssuingDesign unique ids. ex: ["5656565656565656", "4545454545454545"]
    - `:embosser_ids` [list of strings, default nil]: Embosser unique ids. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:expand` [list of strings, default nil]: fields to expand information. ex: ["balance"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingStock structs with updated attributes
    - cursor to retrieve the next page of IssuingStock structs
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
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [IssuingStock.t()]}} |
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
    design_ids: [binary],
    embosser_ids: [binary],
    ids: [binary],
    expand: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    [IssuingStock.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

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
      embosser_name: json[:embosser_name],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
