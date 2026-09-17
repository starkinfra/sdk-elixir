defmodule StarkInfra.PixPullSubscription do
  alias __MODULE__, as: PixPullSubscription
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.Parse
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups PixPullSubscription related functions
  """

  @doc """
  PixPullSubscriptions are recurring Pix debit authorizations. A subscription defines
  the frequency, amount, and required payer authorizations for a series of Pix debits
  to be pulled from the sender by the receiver. Each cycle of an active subscription
  is triggered by a PixPullRequest (its subscriptionId references the subscription's id).
  When you initialize a PixPullSubscription, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the list of created structs.

  ## Parameters (required):
    - `:bacen_id` [string]: Central Bank's unique recurrency id. Identifies the subscription in the Pix infrastructure.
    - `:external_id` [string]: safe string that must be unique among all your Pix Pull Subscriptions. Used for idempotency.
    - `:installment_start` [DateTime, Date or string]: start datetime of settlements allowed for this subscription. ISO 8601. ex: "2026-03-10T19:32:35.418698+00:00"
    - `:interval` [string]: cycle definition. Options: "week", "month", "quarter", "semester", "year"
    - `:receiver_name` [string]: receiver's full name. ex: "Edward Stark"
    - `:receiver_tax_id` [string]: receiver's tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:receiver_bank_code` [string]: receiver's bank institution code.
    - `:reference_code` [string]: commercial-relation identifier. May be a contract number, order id, or client code.
    - `:sender_account_number` [string]: sender's bank account number. Use '-' before the verifier digit. ex: "876543-2"
    - `:sender_bank_code` [string]: sender's bank institution code in Brazil. ex: "20018183"
    - `:sender_branch_code` [string]: sender's bank account branch code. Use '-' in case there is a verifier digit. ex: "1357-9"
    - `:sender_city_code` [string]: IBGE code of the payer's city.
    - `:sender_tax_id` [string]: sender's tax ID (CPF or CNPJ). Same format rules as receiver_tax_id.

  ## Parameters (conditionally required):
    - `:amount` [integer, default nil]: amount in cents charged every cycle. Required if the subscription has a fixed value; omit for variable-amount subscriptions. At least one of `:amount` or `:amount_min_limit` MUST be provided. ex: 11234 (= R$ 112.34)
    - `:amount_min_limit` [integer, default nil]: floor value for the maximum amount the sender can set when approving. Used for variable-amount subscriptions. At least one of `:amount` or `:amount_min_limit` MUST be provided.

  ## Parameters (optional):
    - `:type` [string, default nil]: subscription journey type. Options: "push", "qrcode", "qrcodeAndPayment", "paymentAndOrQrcode"
    - `:description` [string, default nil]: additional information delivered to the sender.
    - `:due` [DateTime, Date or string, default nil]: due date for the sender's answer (approval or denial).
    - `:installment_end` [DateTime, Date or string, default nil]: end datetime of settlements allowed for this subscription.
    - `:pull_retry_limit` [integer, default nil]: max number of retries the receiver may issue for a single failed pull cycle.
    - `:sender_final_name` [string, default nil]: final sender name when the sender differs from the originating institution.
    - `:sender_final_tax_id` [string, default nil]: final sender tax ID. Same format rules as sender_tax_id.
    - `:tags` [list of strings, default nil]: list of strings for reference when searching for PixPullSubscriptions. ex: ["employees", "monthly"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the PixPullSubscription is created. ex: "5656565656565656"
    - `:status` [string]: current lifecycle state. Options: "active", "approved", "canceled", "created", "denied", "expired", "failed", "pending"
    - `:flow` [string]: direction of money flow. Options: "in", "out"
    - `:created` [DateTime]: creation datetime for the PixPullSubscription. ex: ~U[2026-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the PixPullSubscription. ex: ~U[2026-3-10 10:30:0:0]
  """
  @enforce_keys [
    :bacen_id,
    :external_id,
    :installment_start,
    :interval,
    :receiver_name,
    :receiver_tax_id,
    :receiver_bank_code,
    :reference_code,
    :sender_account_number,
    :sender_bank_code,
    :sender_branch_code,
    :sender_city_code,
    :sender_tax_id
  ]
  defstruct [
    :bacen_id,
    :external_id,
    :installment_start,
    :interval,
    :receiver_name,
    :receiver_tax_id,
    :receiver_bank_code,
    :reference_code,
    :sender_account_number,
    :sender_bank_code,
    :sender_branch_code,
    :sender_city_code,
    :sender_tax_id,
    :type,
    :amount,
    :amount_min_limit,
    :description,
    :due,
    :installment_end,
    :pull_retry_limit,
    :sender_final_name,
    :sender_final_tax_id,
    :tags,
    :id,
    :status,
    :flow,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of PixPullSubscription structs for creation in the Stark Infra API.
  Only one automatic debit settles per interval cycle: weekly cycles anchor on the weekday of the
  first installment; month/quarter/semester/year cycles anchor on its calendar day (rolling to the
  next available date, but keeping the original day as the reference, when a given month lacks it).
  If pull_retry_limit allows retries, they may occur starting one day before the expected settlement
  date, up to 3 times within 7 days of the original date, always for the same amount, and never
  inside a new cycle window.

  ## Parameters (required):
    - `:subscriptions` [list of PixPullSubscription structs]: list of 1 to 100 PixPullSubscription structs to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixPullSubscription structs with updated attributes
  """
  @spec create(
    [PixPullSubscription.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [PixPullSubscription.t()]} |
    {:error, [error: Error.t()]}
  def create(subscriptions, options \\ []) do
    Rest.post(
      resource(),
      subscriptions,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    [PixPullSubscription.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(subscriptions, options \\ []) do
    Rest.post!(
      resource(),
      subscriptions,
      options
    )
  end

  @doc """
  Receive a single PixPullSubscription struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixPullSubscription struct with updated attributes
  """
  @spec get(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixPullSubscription.t()} |
    {:error, [error: Error.t()]}
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
    user: Project.t() | Organization.t() | nil
  ) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(
      resource(),
      id,
      options
    )
  end

  @doc """
  Receive a stream of PixPullSubscription structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2026-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2026-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "active", "canceled", "failed"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:flows` [list of strings, default nil]: direction of money flow to filter retrieved structs. Options: "in", "out".
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixPullSubscription structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    flows: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [PixPullSubscription.t()]} |
    {:error, [error: Error.t()]}
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
    flows: [binary],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 PixPullSubscription structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2026-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2026-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "active", "canceled", "failed"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:flows` [list of strings, default nil]: direction of money flow to filter retrieved structs. Options: "in", "out".
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixPullSubscription structs with updated attributes
    - cursor to retrieve the next page of PixPullSubscription structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    flows: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [PixPullSubscription.t()]}} |
    {:error, [error: Error.t()]}
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
    flows: [binary],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Update a PixPullSubscription's mutable parameters by passing its id.
  When patching `:status` to "confirmed", `:sender_city_code` MUST be present in the patch.

  ## Parameters (required):
    - `:id` [string]: PixPullSubscription unique id. ex: "5656565656565656"
    - `:status` [string]: new status to set. ex: "confirmed". When set to "confirmed", `:sender_city_code` is required.

  ## Parameters (conditionally required):
    - `:sender_city_code` [string, default nil]: IBGE code of the payer's city. Required when `:status` is being set to "confirmed".

  ## Parameters (optional):
    - `:reason` [string, default nil]: reason for the patch. Options: "accountClosed", "accountBlocked", "invalidBranchCode", "notRecognizedBySender", "userRejected", "notOffered"
    - `:amount` [integer, default nil]: new amount in cents.
    - `:amount_min_limit` [integer, default nil]: new amount minimum limit.
    - `:due` [DateTime, Date or string, default nil]: new due date for the sender's answer.
    - `:pull_retry_limit` [integer, default nil]: new max number of retries.
    - `:tags` [list of strings, default nil]: new list of tags.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixPullSubscription struct with updated attributes
  """
  @spec update(
    binary,
    status: binary,
    sender_city_code: binary,
    reason: binary,
    amount: integer,
    amount_min_limit: integer,
    due: Date.t() | DateTime.t() | binary,
    pull_retry_limit: integer,
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixPullSubscription.t()} |
    {:error, [error: Error.t()]}
  def update(id, status, parameters \\ []) do
    parameters = [status: status] ++ parameters
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
    binary,
    status: binary,
    sender_city_code: binary,
    reason: binary,
    amount: integer,
    amount_min_limit: integer,
    due: Date.t() | DateTime.t() | binary,
    pull_retry_limit: integer,
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def update!(id, status, parameters \\ []) do
    parameters = [status: status] ++ parameters
    Rest.patch_id!(
      resource(),
      id,
      parameters
    )
  end

  @doc """
  Cancel a PixPullSubscription entity previously created in the Stark Infra API.
  `:reason` is sent as a query parameter on the DELETE request.

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:reason` [string, default nil]: reason why the PixPullSubscription is being canceled. As receiver: "accountClosed", "receiverOrganizationClosed", "receiverInternalError", "fraud", "receiverUserRequested", "paymentNotFound". As sender: "accountClosed", "senderDeceased", "fraud", "senderUserRequested", "paymentNotFound".
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled PixPullSubscription struct
  """
  @spec cancel(
    id: binary,
    reason: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixPullSubscription.t()} |
    {:error, [error: Error.t()]}
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
    reason: binary,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def cancel!(id, options \\ []) do
    Rest.delete_id!(
      resource(),
      id,
      options
    )
  end

  @doc """
  Create a single PixPullSubscription struct from a content string received from a handler
  listening at the subscription url.
  If the provided digital signature does not check out with the StarkInfra public key, a
  StarkInfra.Error will be raised.

  ## Parameters (required):
    - `:content` [string]: response content from request received at user endpoint (not parsed)
    - `:signature` [string]: base-64 digital signature received at response header "Digital-Signature"

  ## Options:
    - `:cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Parsed PixPullSubscription struct
  """
  @spec parse(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  ) ::
    {:ok, PixPullSubscription.t()} |
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
      key: nil,
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
  ) :: any
  def parse!(options \\ []) do
    %{content: content, signature: signature, cache_pid: cache_pid, user: user} =
      Enum.into(
        options |> Check.enforced_keys([:content, :signature]),
        %{cache_pid: nil, user: nil}
      )
    Parse.parse_and_verify!(
      content: content,
      signature: signature,
      cache_pid: cache_pid,
      key: nil,
      resource_maker: &resource_maker/1,
      user: user
    )
  end

  @doc false
  def resource() do
    {
      "PixPullSubscription",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %PixPullSubscription{
      bacen_id: json[:bacen_id],
      external_id: json[:external_id],
      installment_start: json[:installment_start] |> Check.datetime(),
      interval: json[:interval],
      receiver_name: json[:receiver_name],
      receiver_tax_id: json[:receiver_tax_id],
      receiver_bank_code: json[:receiver_bank_code],
      reference_code: json[:reference_code],
      sender_account_number: json[:sender_account_number],
      sender_bank_code: json[:sender_bank_code],
      sender_branch_code: json[:sender_branch_code],
      sender_city_code: json[:sender_city_code],
      sender_tax_id: json[:sender_tax_id],
      type: json[:type],
      amount: json[:amount],
      amount_min_limit: json[:amount_min_limit],
      description: json[:description],
      due: json[:due] |> Check.date_or_datetime(),
      installment_end: json[:installment_end] |> Check.date_or_datetime(),
      pull_retry_limit: json[:pull_retry_limit],
      sender_final_name: json[:sender_final_name],
      sender_final_tax_id: json[:sender_final_tax_id],
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      flow: json[:flow],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
