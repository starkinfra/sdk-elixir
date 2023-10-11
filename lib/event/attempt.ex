defmodule StarkInfra.Event.Attempt do
  alias __MODULE__, as: Attempt
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups Event.Attempt related functions
  """

  @doc """
  When an Event delivery fails, an event attempt will be registered.
  It carries information meant to help you debug event reception issues.

  ## Attributes (return-only):
    - `:id` [binary]: unique id that identifies the delivery attempt. ex: "5656565656565656"
    - `:code` [binary]: delivery error code. ex: "badHttpStatus", "badConnection", "timeout"
    - `:message` [binary]: delivery error full description. ex: "HTTP POST request returned status 404"
    - `:event_id` [binary]: ID of the Event whose delivery failed. ex: "4848484848484848"
    - `:webhook_id` [binary]: ID of the Webhook that triggered this event. ex: "5656565656565656"
    - `:created` [DateTime]: datetime representing the moment when the attempt was made. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:id, :code, :message, :webhook_id, :event_id, :created]
  defstruct [:id, :code, :message, :webhook_id, :event_id, :created]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single Event.Attempt object previously created by the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Event.Attempt object that corresponds to the given id.
  """
  @spec get(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, Attempt.t()} |
    {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: Attempt.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of Event.Attempt objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:event_ids` [list of binaries, default nil]: list of Event ids to filter attempts. ex: ["5656565656565656", "4545454545454545"]
    - `:webhook_ids` [list of binaries, default nil]: list of Webhook ids to filter attempts. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of Event.Attempt objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    event_ids: [binary],
    webhook_ids: [binary],
    user: Project.t() | Organization.t()
  ) ::
    ({:cont, {:ok, [Attempt.t()]}} |
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
    event_ids: [binary],
    webhook_ids: [binary],
    user: Project.t() | Organization.t()
  ) ::
    ({:cont, [Attempt.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 Event.Attempt objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:event_ids` [list of binaries, default nil]: list of Event ids to filter attempts. ex: ["5656565656565656", "4545454545454545"]
    - `:webhook_ids` [list of binaries, default nil]: list of Webhook ids to filter attempts. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of Event.Attempt objects with updated attributes
    - cursor to retrieve the next page of Event.Attempt objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    event_ids: [binary],
    webhook_ids: [binary],
    user: Project.t() | Organization.t()
  ) ::
    {:ok, {binary, [Attempt.t()]}} |
    {:error, [%Error{}]}
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
    event_ids: [binary],
    webhook_ids: [binary],
    user: Project.t() | Organization.t()
  ) :: [Attempt.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "EventAttempt",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Attempt{
      id: json[:id],
      code: json[:code],
      message: json[:message],
      webhook_id: json[:webhook_id],
      event_id: json[:event_id],
      created: json[:created] |> Check.datetime()
    }
  end
end
