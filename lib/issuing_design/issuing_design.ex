defmodule StarkInfra.IssuingDesign do
  alias __MODULE__, as: IssuingDesign
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IssuingDesign related functions
  """

  @doc """
  The IssuingDesign struct displays information on the card and card package designs available to your Workspace.

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when IssuingDesign is created. ex: "5656565656565656"
    - `:name` [string, default nil]: card or package design name. ex: "stark-plastic-dark-001"
    - `:embosser_ids` [list of strings, default nil]: list of embosser unique ids. ex: ["5136459887542272", "5136459887542273"]
    - `:type` [string, default nil]: card or package design type. Options: "card", "envelope"
    - `:updated` [DateTime, default nil]: latest update datetime for the IssuingDesign.
    - `:created` [DateTime, default nil]: creation datetime for the IssuingDesign.
  """
  @enforce_keys [
    :id,
    :name,
    :embosser_ids,
    :type,
    :created,
    :updated
  ]
  defstruct [
    :id,
    :name,
    :embosser_ids,
    :type,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single IssuingDesign struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingDesign struct with updated attributes
  """
  @spec get(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, IssuingDesign.t()} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: IssuingDesign.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of IssuingDesign structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingDesign structs with updated attributes
  """
  @spec query(
    limit: integer,
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, {:ok, [IssuingDesign.t()]}} |
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
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, [IssuingDesign.t()]} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 IssuingDesign structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingDesign structs with updated attributes
    - cursor to retrieve the next page of IssuingDesign structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [IssuingDesign.t()]}} |
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
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    [IssuingDesign.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Receive a single IssuingDesign pdf file generated in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingDesign pdf file content
  """
  @spec pdf(
    binary,
    user: Project.t() | Organization.t() | nil
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
    binary,
    user: Project.t() | Organization.t() | nil
  ) :: binary
  def pdf!(id, options \\ []) do
    Rest.get_content!(resource(), id, "pdf", options |> Keyword.delete(:user), options[:user])
  end

  @doc false
  def resource() do
    {
      "IssuingDesign",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingDesign{
      id: json[:id],
      name: json[:name],
      embosser_ids: json[:embosser_ids],
      type: json[:type],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
