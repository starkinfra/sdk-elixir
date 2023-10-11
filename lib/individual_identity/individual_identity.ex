defmodule StarkInfra.IndividualIdentity do
  alias __MODULE__, as: IndividualIdentity
  alias StarkInfra.Error
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization

  @moduledoc """
  Groups IndividualIdentity related functions
  """

  @doc """
  An IndividualDocument represents an individual to be validated. It can have several individual documents attached
  to it, which are used to validate the identity of the individual. Once an individual identity is created, individual
  documents must be attached to it using the created method of the individual document resource. When all the required
  individual documents are attached to an individual identity it can be sent to validation by patching its status to
  processing.

  When you initialize a IndividualIdentity, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the objects
  to the Stark Infra API and returns the list of created objects.

  ## Parameters (required):
    - `:name` [binary]: individual's full name. ex: "Edward Stark".
    - `:tax_id` [binary]: individual's tax ID (CPF). ex: "594.739.480-42"

  ## Parameters (optional):
    - `:tags` [list of binaries, default []]: list of binaries for reference when searching for IndividualIdentitys. ex: [\"employees\", \"monthly\"]

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the IndividualIdentity is created. ex: "5656565656565656"
    - `:status` [binary]: current status of the IndividualIdentity. ex: "created", "canceled", "processing", "failed", "success"
    - `:created` [DateTime]: creation DateTime for the IndividualIdentity. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :name,
    :tax_id
  ]
  defstruct [
    :name,
    :tax_id,
    :tags,
    :id,
    :status,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of IndividualIdentity objects for creation in the Stark Infra API

  ## Parameters (required):
    - `:identities` [list of IndividualIdentity objects]: list of IndividualIdentity objects to be created in the API

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IndividualIdentity objects with updated attributes
  """
  @spec create(
    [IndividualIdentity.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [IndividualIdentity.t()]} |
    {:error, [Error.t()]}
  def create(identities, options \\ []) do
    Rest.post(
      resource(),
      identities,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    [IndividualIdentity.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(identities, options \\ []) do
    Rest.post!(
      resource(),
      identities,
      options
    )
  end

  @doc """
  Receive a single IndividualIdentity object previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [binary]: object's unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IndividualIdentity object that corresponds to the given id.
  """
  @spec get(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [IndividualIdentity.t()]} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of IndividualIdentity objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020, 3, 10]
    - `:status` [binary, default nil]: filter for status of retrieved objects. ex: ["created", "canceled", "processing", "failed", "success"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IndividualIdentity objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    tags: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, {:ok, [IndividualIdentity.t()]}} |
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
    status: binary,
    tags: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, [IndividualIdentity.t()]} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 IndividualIdentity objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: Date filter for objects created only after specified date. ex: ~D[2020-3-10]
    - `:before` [Date or binary, default nil]: Date filter for objects created only before specified date. ex: ~D(2020-3-10]
    - `:status` [binary, default nil]: filter for status of retrieved objects. ex: ["created", "canceled", "processing", "failed", "success"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IndividualIdentity objects with updated attributes
    - cursor to retrieve the next page of IndividualIdentity objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    tags: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [IndividualIdentity.t()]}} |
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
    status: binary,
    tags: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    [IndividualIdentity.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Update an IndividualIdentity by passing id.

  ## Parameters (required):
    - `:id` [binary]: IndividualIdentity id. ex: '5656565656565656'
    - `:status` [binary]: You may send IndividualDocuments to validation by passing 'processing' in the status

  ## Parameters (Optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target IndividualIdentity with updated attributes
  """
  @spec update(
    id: binary,
    status: binary,
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, IndividualIdentity.t()} |
    {:error, [Error.t()]}
  def update(id, parameters \\ []) do
    Rest.patch_id(
      resource(),
      id,
      parameters
    )
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(
    id: binary,
    status: binary,
    user: (Organization.t() | Project.t() | nil)
  ) :: any
  def update!(id, parameters \\ []) do
    Rest.patch_id!(
      resource(),
      id,
      parameters
    )
  end

  @doc """
    Cancel an IndividualIdentity entity previously created in the Stark Infra API.

  ## Parameters (required):
    - `:id` [binary]: IndividualIdentity unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled IndividualIdentity object
  """
  @spec cancel(
    id: binary,
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, IndividualIdentity.t()} |
    {:error, [Error.t()]}
  def cancel(id, options \\ []) do
    Rest.delete_id(
      resource(),
      id,
      options
    )
  end

  @doc """
  Same as cancel(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec cancel!(
    id: binary,
    user: (Organization.t() | Project.t() | nil)
  ) :: any
  def cancel!(id, options \\ []) do
    Rest.delete_id!(
      resource(),
      id,
      options
    )
  end

  @doc false
  def resource() do
    {
      "IndividualIdentity",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IndividualIdentity{
      name: json[:name],
      tax_id: json[:tax_id],
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      created: json[:created],
    }
  end
end
