defmodule StarkInfra.PixChargeback do
  alias __MODULE__, as: PixChargeback
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups PixChargeback related functions
  """

  @doc """
  A Pix chargeback can be created when fraud is detected on a transaction or a system malfunction
  results in an erroneous transaction.
  It notifies another participant of your request to reverse the payment they have received.

  When you initialize a PixChargeback, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the objects
  to the Stark Infra API and returns the created object.

  ## Parameters (required):
    - `:amount` [integer]: amount in cents to be reversed. ex: 11234 (= R$ 112.34)
    - `:reference_id` [binary]: end_to_end_id or return_id of the transaction to be reversed. ex: "E20018183202201201450u34sDGd19lz"
    - `:reason` [binary]: reason why the reversal was requested. Options: "fraud", "flaw", "reversalChargeback"

  ## Parameters (optional):
    - `:description` [binary, default nil]: description for the PixChargeback.
    - `:tags` [list of binaries, default []]: list of binaries for tagging. ex: ["travel", "food"]

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the PixChargeback is created. ex: "5656565656565656"
    - `:analysis` [binary]: analysis that led to the result.
    - `:sender_bank_code` [binary]: bank_code of the Pix participant that created the PixChargeback. ex: "20018183"
    - `:receiver_bank_code` [binary]: bank_code of the Pix participant that received the PixChargeback. ex: "20018183"
    - `:rejection_reason` [binary]: reason for the rejection of the Pix chargeback. ex: "noBalance", "accountClosed", "unableToReverse"
    - `:reversal_reference_id` [binary]: return id of the reversal transaction. ex: "D20018183202202030109X3OoBHG74wo".
    - `:result` [binary]: result after the analysis of the PixChargeback by the receiving party. ex: "rejected", "accepted", "partiallyAccepted"
    - `:flow` [binary]: direction of the Pix Chargeback. ex: "in" for received chargebacks, "out" for chargebacks you requested
    - `:status` [binary]: current PixChargeback status. ex: "created", "failed", "delivered", "closed", "canceled".
    - `:created` [DateTime]: creation datetime for the PixChargeback. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the PixChargeback. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :amount,
    :reference_id,
    :reason
  ]
  defstruct [
    :amount,
    :reference_id,
    :reason,
    :description,
    :tags,
    :id,
    :analysis,
    :sender_bank_code,
    :receiver_bank_code,
    :rejection_reason,
    :reversal_reference_id,
    :result,
    :flow,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Create a PixChargeback in the Stark Infra API

  ## Parameters (required):
    - `:chargebacks` [list of PixChargeback objects]: list of PixChargeback objects to be created in the API.

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixChargeback objects with updated attributes
  """
  @spec create(
    chargebacks: [PixChargeback.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [PixChargeback.t()]} |
    {:error, Error.t()}
  def create(chargebacks, options \\ []) do
    Rest.post(
      resource(),
      chargebacks,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    chargebacks: [PixChargeback.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(chargebacks, options \\ []) do
    Rest.post!(
      resource(),
      chargebacks,
      options
    )
  end

  @doc """
  Retrieve the PixChargeback object linked to your Workspace in the Stark Infra API using its id.

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656".

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixChargeback object that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, PixChargeback.t()} |
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
  Receive a stream of PixChargeback objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or binary, default nil]: date filter for objects created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["created", "failed", "delivered", "closed", "canceled"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:flow` [binary, default nil]: direction of the Pix Chargeback. ex: "in" for received chargebacks, "out" for chargebacks you requested
    - `:tags` [list of binaries, default nil]: filter for tags of retrieved objects. ex: ["travel", "food"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixChargeback objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    ids: [binary],
    flow: binary,
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [PixChargeback.t()]} |
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
    flow: binary,
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
  Receive a list of up to 100 PixChargeback objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or binary, default nil]: date filter for objects created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["created", "failed", "delivered", "closed", "canceled"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:flow` [binary, default nil]: direction of the Pix Chargeback. ex: "in" for received chargebacks, "out" for chargebacks you requested
    - `:tags` [list of binaries, default nil]: filter for tags of retrieved objects. ex: ["travel", "food"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixChargeback objects with updated attributes
    - cursor to retrieve the next page of PixChargeback objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    ids: [binary],
    flow: binary,
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [PixChargeback.t()]}} |
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
    flow: binary,
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
  Respond to a received PixChargeback.

  ## Parameters (required):
    - `:id` [binary]: PixChargeback id. ex: '5656565656565656'
    - `:result` [binary]: result after the analysis of the PixChargeback. ex: "rejected", "accepted", "partiallyAccepted".

  ## Parameters (conditionally required):
    - `:rejection_reason` [binary, default nil]: if the PixChargeback is rejected a reason is required. ex: "noBalance", "accountClosed", "unableToReverse",
    - `:reversal_reference_id` [binary, default nil]: return_id of the reversal transaction. ex: "D20018183202201201450u34sDGd19lz"

  ## Parameters (optional):
    - `:analysis` [binary, default nil]: description of the analysis that led to the result.
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixChargeback object with updated attributes
  """
  @spec update(
    binary,
    result: binary,
    rejection_reason: binary,
    reversal_reference_id: binary,
    analysis: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixChargeback.t()} |
    {:error, [%Error{}]}
  def update(id, result, parameters \\ []) do
    parameters = [result: result] ++ parameters
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
    result: binary,
    rejection_reason: binary,
    reversal_reference_id: binary,
    analysis: binary,
    user: Project.t() | Organization.t()
  ) :: any
  def update!(id, result, parameters \\ []) do
    parameters = [result: result] ++ parameters
    Rest.patch_id!(
      resource(),
      id,
      parameters
    )
  end

  @doc """
  Cancel a PixChargeback entity previously created in the Stark Infra API

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled PixChargeback object
  """
  @spec cancel(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, PixChargeback.t()} |
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
      "PixChargeback",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %PixChargeback{
      id: json[:id],
      amount: json[:amount],
      reference_id: json[:reference_id],
      reason: json[:reason],
      description: json[:description],
      tags: json[:tags],
      analysis: json[:analysis],
      sender_bank_code: json[:sender_bank_code],
      receiver_bank_code: json[:receiver_bank_code],
      rejection_reason: json[:rejection_reason],
      reversal_reference_id: json[:reversal_reference_id],
      result: json[:result],
      flow: json[:flow],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime(),
    }
  end
end
