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
  The IssuingDesign object displays information on the card and card package designs available to your Workspace.

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when IssuingDesign is created. ex: "5656565656565656"
    - `:name` [binary]: card or package design name. ex: "stark-plastic-dark-001"
    - `:embosser_ids` [list of binaries]: list of embosser unique ids. ex: ["5136459887542272", "5136459887542273"]
    - `:type` [binary]: card or package design type. Options: "card", "envelope"
    - `:updated` [DateTime]: latest update DateTime for the IssuingDesign. ex: ~U[2020-3-10 10:30:0:0]
    - `:created` [DateTime]: creation datetime for the IssuingDesign. ex: ~U[2020-03-10 10:30:0:0]
  """

  @enforce_keys [
    :id,
    :name,
    :embosser_ids,
    :type,
    :updated,
    :created
  ]
  defstruct [
    :id,
    :name,
    :embosser_ids,
    :type,
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of IssuingDesign objects previously created in the Stark Infra API.

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingDesign objects with updated attributes
  """
  @spec query(
    limit: integer,
    ids: [binary],
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, [IssuingDesign.t()]} |
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
    user: (Organization.t() | Project.t() | nil)
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of IssuingDesign previously created in the Stark Infra API and the cursor to the next page.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingDesign objects with updated attributes
    - cursor to retrieve the next page of IssuingDesign objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    ids: [binary],
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, {binary, [IssuingDesign.t()]}} |
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
    user: (Organization.t() | Project.t() | nil)
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Receive a single IssuingDesign objects previously created in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingDesign objects that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, IssuingDesign.t()} |
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
  Receive a single IssuingDesign pdf file generated in the Stark Infra API by its id.

  ## Parameters (required):
    - `id` [string]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingDesign pdf file content
  """
  @spec pdf(
    id: binary,
    user: Project.t() | Organization.t() | nil
    ) ::
      {:ok, binary} |
      {:error, [%Error{}]}
  def pdf(id, options \\ []) do
    Rest.get_content(
      resource(),
      id,
      "pdf",
      options |> Keyword.delete(:user), options[:user]
    )
  end

  @doc """
  Same as pdf(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec pdf!(
    id: binary,
    user: Project.t() | Organization.t() | nil
    ) :: binary
  def pdf!(id, options \\ []) do
    Rest.get_content!(
      resource(),
      id,
      "pdf",
      options |> Keyword.delete(:user), options[:user])
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
