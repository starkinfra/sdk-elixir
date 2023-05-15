defmodule StarkInfra.CreditHolmes.Log do
  alias __MODULE__, as: Log
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Check
  alias StarkInfra.CreditHolmes
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups CreditHolmes.Log related functions
  """
  @doc """
  Every time an CreditHolmes entity is updated, a corresponding CreditHolmes.Log
  is generated for the entity. This log is never generated by the user, but
  it can be retrieved to check additional information on the CreditHolmes.

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the log is created. ex: "5656565656565656"
    - `:holmes` [CreditHolmes]: CreditHolmes entity to which the log refers to.
    - `:errors` [list of binaries]: list of errors linked to this CreditHolmes event
    - `:type` [binary]: type of the CreditHolmes event which triggered the log creation. ex: "created", "failed", "success"
    - `:created` [DateTime, default nil]: creation DateTime for the Log. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :id,
    :holmes,
    :errors,
    :type,
    :created
  ]
  defstruct [
    :id,
    :holmes,
    :errors,
    :type,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single CreditHolmes.Log object previously created by the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CreditHolmes.Log object that corresponds to the given id.
  """
  @spec get(
    binary,
    user: Project.t() |
    Organization.t() | nil
  ) ::
    {:ok, [Log.t()]} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(
    binary,
    user: Project.t() | Organization.t() | nil
  ) :: Log.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of CreditHolmes.Log objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: datetime.date(2020, 3, 10)
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: datetime.date(2020, 3, 10)
    - `:types` [list of strings, default nil]: filter for log event types. ex: ["canceled", "created", "expired", "failed", "refunded", "registered", "sending", "sent", "signed", "success"]
    - `:holmes_ids` [list of strings, default nil]: list of CreditHolmes ids to filter logs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CreditHolmes.Log objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    types: [binary],
    holmes_ids: [binary],
    user: Project.t() | Organization.t()
  ) ::
    ({:cont, {:ok, [Log.t()]}} |
    {:error, [Error.t()]},
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
    types: [binary],
    holmes_ids: [binary],
    user: Project.t() | Organization.t()
  ) :: [Log.t()]
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 CreditHolmes.Log objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: datetime.date(2020, 3, 10)
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: datetime.date(2020, 3, 10)
    - `:types` [list of strings, default nil]: filter for log event types. ex: ["canceled", "created", "expired", "failed", "refunded", "registered", "sending", "sent", "signed", "success"]
    - `:holmes_ids` [list of strings, default nil]: list of CreditHolmes ids to filter logs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CreditHolmes.Log objects with updated attributes
    - cursor to retrieve the next page of CreditHolmes.Log objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    types: [binary],
    holmes_ids: [binary],
    user: Project.t() | Organization.t()
  ) ::
    {:ok, {binary, [Invoice.t()]}} |
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
    holmes_ids: [binary],
    user: Project.t() | Organization.t()
  ) ::
    [Log.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "CreditHolmesLog",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Log{
      id: json[:id],
      holmes: json[:holmes] |> API.from_api_json(&CreditHolmes.resource_maker/1),
      created: json[:created] |> Check.datetime(),
      type: json[:type],
      errors: json[:errors]
    }
  end
end