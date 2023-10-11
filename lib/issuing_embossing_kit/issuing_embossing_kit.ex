defmodule StarkInfra.IssuingEmbossingKit do
  alias __MODULE__, as: IssuingEmbossingKit
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.API
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.IssuingDesign
  alias StarkInfra.Error

  @moduledoc """
    Groups IssuingEmbossingKit related functions
  """

  @doc """
  The IssuingEmbossingKit object displays information on the embossing kits available to your Workspace.

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when IssuingEmbossingKit is created. ex: "5656565656565656"
    - `:name` [binary]: embossing kit name. ex: "stark-plastic-dark-001"
    - `:designs` [list of IssuingDesign objects]: status of the IssuingDesign objects.
    - `:updated` [DateTime]: latest update datetime for the IssuingEmbossingKit.
    - `:created` [DateTime]: creation datetime for the IssuingEmbossingKit.
  """

  @enforce_keys [
    :id,
    :name,
    :designs,
    :updated,
    :created
  ]
  defstruct [
    :id,
    :name,
    :designs,
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of IssuingEmbossingKit objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "success", "failed"]
    - `:design_ids` [list of binaries, default nil]: list of design_ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingEmbossingKit objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    design_ids: [binary],
    ids: [binary],
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, [IssuingEmbossingKit.t()]} |
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
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    design_ids: [binary],
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
  Receive a list of IssuingEmbossingKit previously created in the Stark Infra API and the cursor to the next page.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "success", "failed"]
    - `:design_ids` [list of binaries, default nil]: list of design_ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingEmbossingKit objects with updated attributes
    - cursor to retrieve the next page of IssuingEmbossingKit objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    design_ids: [binary],
    ids: [binary],
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, {binary, [IssuingEmbossingKit.t()]}} |
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
    design_ids: [binary],
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
  Receive a single IssuingEmbossingKit objects previously created in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingEmbossingKit objects that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, IssuingEmbossingKit.t()} |
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

  @doc false
  def resource() do
    {
      "IssuingEmbossingKit",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingEmbossingKit{
      id: json[:id],
      name: json[:name],
      designs: json[:designs] |> Enum.map(fn design -> API.from_api_json(design, &IssuingDesign.resource_maker/1) end),
      updated: json[:updated],
      created: json[:created]
    }
  end
end
