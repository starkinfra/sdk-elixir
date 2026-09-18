defmodule StarkInfra.IssuingTokenDesign do
  alias __MODULE__, as: IssuingTokenDesign
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IssuingTokenDesign related functions
  """

  @doc """
  The IssuingTokenDesign struct displays the information of the token designs created in your Workspace.
  This resource represents the existing designs for the cards which will be tokenized.

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the IssuingTokenDesign is created. ex: "5656565656565656"
    - `:name` [string]: design name. ex: "Stark Bank - White Metal"
    - `:created` [DateTime]: creation datetime for the IssuingTokenDesign. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the IssuingTokenDesign. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :id,
    :name,
    :created,
    :updated
  ]
  defstruct [
    :id,
    :name,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single IssuingTokenDesign struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingTokenDesign struct with updated attributes
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IssuingTokenDesign.t()} |
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
  Receive a stream of IssuingTokenDesign structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingTokenDesign structs with updated attributes
  """
  @spec query(
    limit: integer,
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [IssuingTokenDesign.t()]} |
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
  @spec query!(
    limit: integer,
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
  Receive a list of up to 100 IssuingTokenDesign structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingTokenDesign structs with updated attributes
    - cursor to retrieve the next page of IssuingTokenDesign structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IssuingTokenDesign.t()]}} |
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
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Receive a single IssuingTokenDesign pdf file generated in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingTokenDesign pdf file content
  """
  @spec pdf(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, binary} |
    {:error, [Error.t()]}
  def pdf(id, options \\ []) do
    Rest.get_content(resource(), id, "pdf", options |> Keyword.delete(:user), options[:user])
  end

  @doc """
  Same as pdf(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec pdf!(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def pdf!(id, options \\ []) do
    Rest.get_content!(resource(), id, "pdf", options |> Keyword.delete(:user), options[:user])
  end

  @doc false
  def resource() do
    {
      "IssuingTokenDesign",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingTokenDesign{
      id: json[:id],
      name: json[:name],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
