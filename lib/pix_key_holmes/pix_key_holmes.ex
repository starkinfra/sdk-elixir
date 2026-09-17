defmodule StarkInfra.PixKeyHolmes do
  alias __MODULE__, as: PixKeyHolmes
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups PixKeyHolmes related functions
  """

  @doc """
  PixKeyHolmes are used to investigate the registration status of a Pix Key
  in the Central Bank's DICT.
  When you initialize a PixKeyHolmes, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:key_id` [string]: Pix Key to be investigated. ex: "+5511989898989", "11.222.333/0001-00", "valid@sandbox.com"

  ## Parameters (optional):
    - `:tags` [list of strings, default []]: list of strings for reference when searching for PixKeyHolmes. ex: ["employees", "monthly"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the PixKeyHolmes is created. ex: "5656565656565656"
    - `:result` [string]: result of the investigation. Options: "registered", "unregistered". Empty until the status is "solved".
    - `:status` [string]: current PixKeyHolmes status. Options: "created", "solving", "solved", "failed"
    - `:created` [DateTime]: creation datetime for the PixKeyHolmes. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the PixKeyHolmes. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :key_id
  ]
  defstruct [
    :key_id,
    :tags,
    :id,
    :result,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Create PixKeyHolmes in the Stark Infra API

  ## Parameters (required):
    - `:holmes` [list of PixKeyHolmes]: list of PixKeyHolmes structs to be created in the API. You can send up to 100 PixKeyHolmes structs in a single request.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixKeyHolmes structs with updated attributes
  """
  @spec create(
    holmes: [PixKeyHolmes.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [PixKeyHolmes.t()]} |
    {:error, Error.t()}
  def create(holmes, options \\ []) do
    Rest.post(
      resource(),
      holmes,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    holmes: [PixKeyHolmes.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(holmes, options \\ []) do
    Rest.post!(
      resource(),
      holmes,
      options
    )
  end

  @doc """
  Retrieve the PixKeyHolmes struct linked to your Workspace in the Stark Infra API using its id.

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656".

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixKeyHolmes struct that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, PixKeyHolmes.t()} |
    {:error, Error.t()}
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
  Receive a stream of PixKeyHolmes structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: ["created", "solving", "solved", "failed"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["employees", "monthly"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixKeyHolmes structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [PixKeyHolmes.t()]} |
    {:error, Error.t()}
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
    status: [binary],
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
  Receive a list of up to 100 PixKeyHolmes structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your holmes.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: ["created", "solving", "solved", "failed"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["employees", "monthly"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixKeyHolmes structs with updated attributes
    - cursor to retrieve the next page of PixKeyHolmes structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [PixKeyHolmes.t()]}} |
    {:error, Error.t()}
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

  @doc false
  def resource() do
    {
      "PixKeyHolmes",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %PixKeyHolmes{
      key_id: json[:key_id],
      tags: json[:tags],
      id: json[:id],
      result: json[:result],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime(),
    }
  end
end
