defmodule StarkInfra.Event do
  alias __MODULE__, as: Event
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.API
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error
  alias StarkInfra.Utils.Parse
  alias StarkInfra.CreditNote.Log, as: CreditNote
  alias StarkInfra.IssuingCard.Log, as: IssuingCard
  alias StarkInfra.IssuingInvoice.Log, as: IssuingInvoice
  alias StarkInfra.IssuingPurchase.Log, as: IssuingPurchase
  alias StarkInfra.PixKey.Log, as: PixKey
  alias StarkInfra.PixClaim.Log, as: PixClaim
  alias StarkInfra.CreditNote.Log, as: CreditNote
  alias StarkInfra.PixRequest.Log, as: PixRequest
  alias StarkInfra.PixReversal.Log, as: PixReversal
  alias StarkInfra.PixChargeback.Log, as: PixChargeback
  alias StarkInfra.PixInfraction.Log, as: PixInfraction

  @moduledoc """
  Groups Webhook-Event related functions
  """

  @doc """
  An Event is the notification received from the subscription to the Webhook.
  Events cannot be created, but may be retrieved from the Stark Infra API to
  list all generated updates on entities.

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the Event is created. ex: "5656565656565656"
    - `:log` [Log]: a Log object from one the subscription services (PixRequest.Log, PixReversal.Log, PixKey.log)
    - `:created` [DateTime]: creation datetime for the notification event. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:is_delivered` [bool]: true if the event has been successfully delivered to the user url. ex: false
    - `:subscription` [binary]: service that triggered this event. ex: "pix-request.in", "pix-request.out", "pix-reversal.in", "pix-reversal.out", "pix-key", "pix-claim", "pix-infraction", "pix-chargeback", "issuing-card", "issuing-invoice", "issuing-purchase", "credit-note"
    - `:workspace_id` [binary]: ID of the Workspace that generated this event. Mostly used when multiple Workspaces have Webhooks registered to the same endpoint. ex: "4545454545454545"
  """
  defstruct [:id, :log, :created, :is_delivered, :subscription, :workspace_id]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single notification Event object previously created in the Stark Infra API by passing its id

  ## Parameters (required):
    - `id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Event object that corresponds to the given id.
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) :: {:ok, Event.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: Event.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of notification Event objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:is_delivered` [bool, default nil]: filter successfully delivered events. ex: true or false
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of Event objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    is_delivered: boolean,
    user: Project.t() | Organization.t()
  ) ::
    ({:cont, {:ok, [Event.t()]}} |
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
    is_delivered: boolean,
    user: Project.t() | Organization.t()
  ) ::
    ({:cont, [Event.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 Event objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:is_delivered` [bool, default nil]: filter successfully delivered events. ex: true or false
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of Event objects with updated attributes
    - cursor to retrieve the next page of Event objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    is_delivered: boolean,
    user: Project.t() | Organization.t()
  ) ::
    {:ok, {binary, [Event.t()]}} |
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
    is_delivered: boolean,
    user: Project.t() | Organization.t()
  ) :: [Event.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Delete a notification Event entity previously created in the Stark Infra API

  ## Parameters (required):
    - `id` [binary]: Event unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - deleted Event object
  """
  @spec delete(binary, user: Project.t() | Organization.t() | nil) :: {:ok, Event.t()} | {:error, [%Error{}]}
  def delete(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(binary, user: Project.t() | Organization.t() | nil) :: Event.t()
  def delete!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
  end

  @doc """
  Update notification Event by passing id.
    If is_delivered is true, the event will no longer be returned on queries with is_delivered=false.

  ## Parameters (required):
    - `id` [list of binaries]: Event unique ids. ex: "5656565656565656"
    - `:is_delivered` [bool]: If true and event hasn't been delivered already, event will be set as delivered. ex: true

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target Event with updated attributes
  """
  @spec update(
    binary,
    is_delivered: bool,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, Event.t()} |
    {:error, [%Error{}]}
  def update(id, parameters \\ []) do
    Rest.patch_id(resource(), id, parameters |> Check.enforced_keys([:is_delivered]) |> Enum.into(%{}))
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(
    binary,
    is_delivered: bool,
    user: Project.t() | Organization.t() | nil
  ) :: Event.t()
  def update!(id, parameters \\ []) do
    Rest.patch_id!(resource(), id, parameters |> Check.enforced_keys([:is_delivered]) |> Enum.into(%{}))
  end

  @doc """
  Create a single Event object received from Event listening at subscribed user endpoint.
  If the provided digital signature does not check out with the StarkInfra public key, a
  Starkinfra.Error.InvalidSignatureError will be raised.

  ## Parameters (required):
    - `:content` [binary]: response content from request received at user endpoint (not parsed)
    - `:signature` [binary]: base-64 digital signature received at response header "Digital-Signature"

  ## Parameters (optional):
    - `cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Parsed Event object
  """
  @spec parse(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  )::
    {:ok, Event.t()} |
    {:error, [error: Error.t()]}
  def parse(options \\ []) do
    %{content: content, signature: signature, cache_pid: cache_pid, user: user} =
    Enum.into(
      options |> Check.enforced_keys([:content, :signature]),
      %{cache_pid: nil, user: nil}
    )
    Parse.parse_and_verify(
      content: content,
      signature: signature,
      cache_pid: cache_pid,
      key: "event",
      resource_maker: &resource_maker/1,
      user: user
    )
  end

  @doc """
  Same as parse(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  ):: any
  def parse!(options \\ []) do
    %{content: content, signature: signature, cache_pid: cache_pid, user: user} =
      Enum.into(
        options |> Check.enforced_keys([:content, :signature]),
        %{cache_pid: nil, user: nil}
      )
    Parse.parse_and_verify(
      content: content,
      signature: signature,
      cache_pid: cache_pid,
      key: "event",
      resource_maker: &resource_maker/1,
      user: user
    )
  end

  defp resource() do
    {
      "Event",
      &resource_maker/1
    }
  end

  defp resource_maker(json) do
    %Event{
      id: json[:id],
      log: parse_log_json(json[:log], json[:subscription]),
      created: json[:created] |> Check.datetime(),
      is_delivered: json[:is_delivered],
      subscription: json[:subscription],
      workspace_id: json[:workspace_id]
    }
  end

  defp parse_log_json(log, subscription) do
    log |> API.from_api_json(log_maker_by_subscription(subscription))
  rescue
    CaseClauseError -> log
  end

  defp log_maker_by_subscription(subscription) do
    case subscription do
      "credit-note" -> &CreditNote.resource_maker/1
      "pix-request.in" -> &PixRequest.resource_maker/1
      "pix-request.out" -> &PixRequest.resource_maker/1
      "pix-reversal.in" -> &PixReversal.resource_maker/1
      "pix-reversal.out" -> &PixReversal.resource_maker/1
      "pix-key" -> &PixKey.resource_maker/1
      "pix-claim" -> &PixClaim.resource_maker/1
      "pix-infraction" -> &PixInfraction.resource_maker/1
      "pix-chargeback" -> &PixChargeback.resource_maker/1
      "issuing-card" -> &IssuingCard.resource_maker/1
      "issuing-invoice" -> &IssuingInvoice.resource_maker/1
      "issuing-purchase" -> &IssuingPurchase.resource_maker/1
    end
  end
end
