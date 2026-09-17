defmodule StarkInfra.PixFraud do
  alias __MODULE__, as: PixFraud
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups PixFraud related functions
  """

  @doc """
  PixFrauds are used to report a PixKey or tax_id when a fraud
  has been confirmed.
  When you initialize a PixFraud, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:external_id` [string]: unique string to prevent duplicates among your PixFrauds. ex: "my-internal-id-123456"
    - `:type` [string]: type of PixFraud. Options: "identity", "mule", "scam", "other"
    - `:tax_id` [string]: user tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"

  ## Parameters (optional):
    - `:key_id` [string, default nil]: marked PixKey id. ex: "+5511989898989"
    - `:tags` [list of strings, default []]: list of strings for tagging. ex: ["fraudulent"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the PixFraud is created. ex: "5656565656565656"
    - `:bacen_id` [string]: unique transaction id returned from Central Bank. ex: "ccf9bd9c-e99d-999e-bab9-b999ca999f99"
    - `:status` [string]: current PixFraud status. Options: "created", "failed", "registered", "canceled".
    - `:created` [DateTime]: creation datetime for the PixFraud. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the PixFraud. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :external_id,
    :type,
    :tax_id
  ]
  defstruct [
    :external_id,
    :type,
    :tax_id,
    :key_id,
    :tags,
    :id,
    :bacen_id,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Create PixFrauds in the Stark Infra API

  ## Parameters (required):
    - `:frauds` [list of PixFraud]: list of PixFraud structs to be created in the API. You can send up to 100 PixFraud structs in a single request.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixFraud structs with updated attributes
  """
  @spec create(
    frauds: [PixFraud.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [PixFraud.t()]} |
    {:error, Error.t()}
  def create(frauds, options \\ []) do
    Rest.post(
      resource(),
      frauds,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    frauds: [PixFraud.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(frauds, options \\ []) do
    Rest.post!(
      resource(),
      frauds,
      options
    )
  end

  @doc """
  Retrieve the PixFraud struct linked to your Workspace in the Stark Infra API using its id.

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656".

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixFraud struct that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, PixFraud.t()} |
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
  Receive a stream of PixFrauds structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: ["created", "failed", "registered", "canceled"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:bacen_id` [string, default nil]: unique transaction id returned from Central Bank. ex: "ccf9bd9c-e99d-999e-bab9-b999ca999f99"
    - `:type` [list of strings, default nil]: filter for the type of retrieved PixFrauds. Options: "identity", "mule", "scam", "other"
    - `:tags` [list of strings, default nil]: list of strings for tagging. ex: ["fraudulent"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixFraud structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    ids: [binary],
    bacen_id: binary,
    type: [binary],
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [PixFraud.t()]} |
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
    ids: [binary],
    bacen_id: binary,
    type: [binary],
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a stream of PixFrauds structs previously created in the Stark Infra API

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: ["created", "failed", "registered", "canceled"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:bacen_id` [string, default nil]: unique transaction id returned from Central Bank. ex: "ccf9bd9c-e99d-999e-bab9-b999ca999f99"
    - `:type` [list of strings, default nil]: filter for the type of retrieved PixFrauds. Options: "identity", "mule", "scam", "other"
    - `:tags` [list of strings, default nil]: list of strings for tagging. ex: ["fraudulent"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixFraud structs with updated attributes
    - cursor to retrieve the next page of PixFraud structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    ids: [binary],
    bacen_id: binary,
    type: [binary],
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [PixFraud.t()]}} |
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
    ids: [binary],
    bacen_id: binary,
    type: [binary],
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Cancel a PixFraud entity previously created in the Stark Infra API

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled PixFraud struct
  """
  @spec cancel(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, PixFraud.t()} |
    {:error, Error.t()}
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
    user: Organization.t() | Project.t() | nil
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
      "PixFraud",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %PixFraud{
      external_id: json[:external_id],
      type: json[:type],
      tax_id: json[:tax_id],
      key_id: json[:key_id],
      tags: json[:tags],
      id: json[:id],
      bacen_id: json[:bacen_id],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime(),
    }
  end
end
