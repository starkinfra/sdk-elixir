defmodule StarkInfra.PixPullRequest do
  alias __MODULE__, as: PixPullRequest
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups PixPullRequest related functions
  """

  @doc """
  A Pix Pull Request is a command sent to the payer's bank to trigger the automatic
  debit linked to an active PixPullSubscription. It confirms the receiver's intent
  to collect the agreed amount within the current billing cycle and initiates the
  settlement process through the Pix infrastructure. Each pull request references a
  parent PixPullSubscription via `:subscription_id`.
  When you initialize a PixPullRequest, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the list of created structs.

  ## Parameters (required):
    - `:amount` [integer]: amount to be charged in cents. ex: 11234 (= R$ 112.34)
    - `:due` [DateTime or string]: due date for answering with an approval or denial. ISO 8601.
    - `:end_to_end_id` [string]: Central Bank's unique transaction id. ex: "E00002649202201172211u34srod19le"
    - `:receiver_account_number` [string]: receiver's bank account number. Use '-' before the verifier digit. ex: "876543-2"
    - `:receiver_account_type` [string]: receiver's account type. Options: "checking", "savings", "salary", "payment"
    - `:receiver_bank_code` [string]: receiver's bank code.
    - `:reconciliation_id` [string]: id used for conciliation of the resulting Pix transaction. Up to 25 alphanumeric chars. ex: "123456"
    - `:subscription_id` [string]: unique id of the parent PixPullSubscription.

  ## Parameters (optional):
    - `:attempt_type` [string, default nil]: defines the type of attempt. Options: "default", "instantRetry", "scheduledRetry".
    - `:description` [string, default nil]: additional information to be delivered to the sender.
    - `:receiver_branch_code` [string, default nil]: receiver's branch code.
    - `:tags` [list of strings, default nil]: list of strings for reference when searching for PixPullRequests. ex: ["employees", "monthly"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the PixPullRequest is created. ex: "5656565656565656"
    - `:status` [string]: current PixPullRequest status. Options: "created", "processing", "scheduled", "denied", "success", "failed", "canceled", "expired"
    - `:flow` [string]: direction of money flow. Options: "in", "out"
    - `:receiver_name` [string]: receiver's full name (filled in by the Pix infrastructure during settlement).
    - `:receiver_tax_id` [string]: receiver's tax ID (CPF or CNPJ).
    - `:sender_bank_code` [string]: sender's bank institution code in Brazil.
    - `:sender_final_name` [string]: sender's final name when the sender differs from the originating institution.
    - `:sender_final_tax_id` [string]: sender's final tax ID (CPF or CNPJ), when different from the account holder.
    - `:sender_tax_id` [string]: sender's tax ID (CPF or CNPJ).
    - `:subscription_bacen_id` [string]: bacenId of the parent subscription, denormalized for convenience.
    - `:created` [DateTime]: creation datetime for the PixPullRequest.
    - `:updated` [DateTime]: latest update datetime for the PixPullRequest.
  """
  @enforce_keys [
    :amount,
    :due,
    :end_to_end_id,
    :receiver_account_number,
    :receiver_account_type,
    :receiver_bank_code,
    :reconciliation_id,
    :subscription_id
  ]
  defstruct [
    :amount,
    :due,
    :end_to_end_id,
    :receiver_account_number,
    :receiver_account_type,
    :receiver_bank_code,
    :reconciliation_id,
    :subscription_id,
    :attempt_type,
    :description,
    :receiver_branch_code,
    :tags,
    :id,
    :status,
    :flow,
    :receiver_name,
    :receiver_tax_id,
    :sender_bank_code,
    :sender_final_name,
    :sender_final_tax_id,
    :sender_tax_id,
    :subscription_bacen_id,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of PixPullRequest structs for creation in the Stark Infra API.
  A request must be sent 2 to 10 days before the intended settlement date, and Stark Infra
  validates that the parent subscription is approved, the amount is within its authorized
  limit, the due date matches the subscription's charge cycle, payer/receiver details match
  the contract, and no other request is already scheduled for the same cycle. As the payer's
  bank, you must attempt settlement in two windows (00h00-08h00 and 18h00-21h00); attempts
  are no longer accepted after 21:00.

  ## Parameters (required):
    - `:requests` [list of PixPullRequest structs]: list of PixPullRequest structs to be created in the API. Min = 1, Max = 100.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixPullRequest structs with updated attributes
  """
  @spec create(
    [PixPullRequest.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [PixPullRequest.t()]} |
    {:error, [error: Error.t()]}
  def create(requests, options \\ []) do
    Rest.post(
      resource(),
      requests,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    [PixPullRequest.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(requests, options \\ []) do
    Rest.post!(
      resource(),
      requests,
      options
    )
  end

  @doc """
  Receive a single PixPullRequest struct previously created in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixPullRequest struct with updated attributes
  """
  @spec get(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixPullRequest.t()} |
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
  Receive a stream of PixPullRequest structs previously created in the Stark Infra API.

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: "created", "processing", "scheduled", "denied", "success", "failed", "canceled", "expired"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["employees", "monthly"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:subscription_ids` [list of strings, default nil]: filter by parent PixPullSubscription ids. ex: ["5656565656565656", "4545454545454545"]
    - `:flows` [list of strings, default nil]: direction of money flow to filter retrieved structs. Options: "in", "out".
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixPullRequest structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    subscription_ids: [binary],
    flows: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [PixPullRequest.t()]} | {:error, [error: Error.t()]}
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
    subscription_ids: [binary],
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
  Receive a list of up to 100 PixPullRequest structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 50
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: "created", "processing", "scheduled", "denied", "success", "failed", "canceled", "expired"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["employees", "monthly"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:subscription_ids` [list of strings, default nil]: filter by parent PixPullSubscription ids. ex: ["5656565656565656", "4545454545454545"]
    - `:flows` [list of strings, default nil]: direction of money flow to filter retrieved structs. Options: "in", "out".
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - cursor to retrieve the next page of PixPullRequest structs
    - stream of PixPullRequest structs with updated attributes
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    subscription_ids: [binary],
    flows: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [PixPullRequest.t()]}} |
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
    subscription_ids: [binary],
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
  Update a PixPullRequest to change its status to "scheduled" or "denied".
  Only the payer may update a pull request.

  ## Parameters (required):
    - `:id` [string]: PixPullRequest unique id. ex: "5656565656565656"
    - `:status` [string]: new status to set. Options: "scheduled", "denied".

  ## Parameters (conditionally required):
    - `:reason` [string, default nil]: required when `:status` is "denied". Options: "senderAccountClosed", "senderAccountBlocked", "amountNotAllowed".

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixPullRequest with updated attributes
  """
  @spec update(
    binary,
    status: binary,
    reason: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixPullRequest.t()} |
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
    reason: binary,
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
  Cancel a PixPullRequest previously created in the Stark Infra API.
  The `:reason` is sent as a query parameter on the DELETE request.

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"
    - `:reason` [string]: cancellation reason. As sender: "accountClosed", "accountBlocked", "pixRequestFailed", "other", "senderUserRequested". As receiver: "accountClosed", "accountBlocked", "other", "receiverUserRequested".

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled PixPullRequest struct
  """
  @spec cancel(
    binary,
    reason: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixPullRequest.t()} |
    {:error, [error: Error.t()]}
  def cancel(id, reason, options \\ []) do
    options = [reason: reason] ++ options
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
    binary,
    reason: binary,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def cancel!(id, reason, options \\ []) do
    options = [reason: reason] ++ options
    Rest.delete_id!(
      resource(),
      id,
      options
    )
  end

  @doc false
  def resource() do
    {
      "PixPullRequest",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %PixPullRequest{
      amount: json[:amount],
      due: json[:due] |> Check.datetime(),
      end_to_end_id: json[:end_to_end_id],
      receiver_account_number: json[:receiver_account_number],
      receiver_account_type: json[:receiver_account_type],
      receiver_bank_code: json[:receiver_bank_code],
      reconciliation_id: json[:reconciliation_id],
      subscription_id: json[:subscription_id],
      attempt_type: json[:attempt_type],
      description: json[:description],
      receiver_branch_code: json[:receiver_branch_code],
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      flow: json[:flow],
      receiver_name: json[:receiver_name],
      receiver_tax_id: json[:receiver_tax_id],
      sender_bank_code: json[:sender_bank_code],
      sender_final_name: json[:sender_final_name],
      sender_final_tax_id: json[:sender_final_tax_id],
      sender_tax_id: json[:sender_tax_id],
      subscription_bacen_id: json[:subscription_bacen_id],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
