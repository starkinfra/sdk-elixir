defmodule StarkInfra.IssuingEmbossingKit do
  alias __MODULE__, as: IssuingEmbossingKit
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error
  alias StarkInfra.IssuingDesign

  @moduledoc """
  Groups IssuingEmbossingKit related functions
  """

  @doc """
  The IssuingEmbossingKit struct displays information on the embossing kits available to your Workspace.

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when IssuingEmbossingKit is created. ex: "5656565656565656"
    - `:name` [string, default nil]: embossing kit name. ex: "stark-plastic-dark-001"
    - `:designs` [list of IssuingDesign structs, default nil]: list of IssuingDesign structs.
    - `:updated` [DateTime, default nil]: latest update datetime for the IssuingEmbossingKit.
    - `:created` [DateTime, default nil]: creation datetime for the IssuingEmbossingKit.
  """
  @enforce_keys [
    :id,
    :name,
    :designs,
    :created,
    :updated
  ]
  defstruct [
    :id,
    :name,
    :designs,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single IssuingEmbossingKit struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingEmbossingKit struct with updated attributes
  """
  @spec get(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, IssuingEmbossingKit.t()} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: IssuingEmbossingKit.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of IssuingEmbossingKit structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil] date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil] date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "processing", "success", "failed"]
    - `:design_ids` [list of strings, default nil]: list of design_ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingEmbossingKit structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    design_ids: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, {:ok, [IssuingEmbossingKit.t()]}} |
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
    design_ids: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, [IssuingEmbossingKit.t()]} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 IssuingEmbossingKit structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or string, default nil] date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil] date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "processing", "success", "failed"]
    - `:design_ids` [list of strings, default nil]: list of design_ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingEmbossingKit structs with updated attributes
    - cursor to retrieve the next page of IssuingEmbossingKit structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    design_ids: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [IssuingEmbossingKit.t()]}} |
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
    design_ids: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    [IssuingEmbossingKit.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
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
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
