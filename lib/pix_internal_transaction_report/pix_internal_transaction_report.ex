defmodule StarkInfra.PixInternalTransactionReport do
  alias __MODULE__, as: PixInternalTransactionReport
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups PixInternalTransactionReport related functions
  """

  @doc """
  PixInternalTransactionReports are used to report transactions that happened
  internally, outside of the SPI, to the Central Bank so they are reflected in
  the participant's statements.
  When you initialize a PixInternalTransactionReport, the entity will not be
  automatically created in the Stark Infra API. The 'create' function sends the
  structs to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:amount` [integer]: amount of the reported transaction in cents. ex: 1234 (= R$ 12.34)
    - `:created` [DateTime or string]: datetime when the reported transaction occurred. ex: ~U[2020-3-10 10:30:0:0]
    - `:end_to_end_id` [string]: central bank's unique transaction id. ex: "E20018183202201201213u34sav898j"
    - `:method` [string]: type of the reported transaction. Options: "manual", "dict", "initiator", "dynamicQrcode", "staticQrcode", "payerQrcode", "subscription", "contactless", "staticContactless"
    - `:reference_type` [string]: type of the reported transaction. Options: "request", "reversal"
    - `:sender_account_number` [string]: sender's bank account number. ex: "76543"
    - `:sender_branch_code` [string]: sender's bank account branch code. ex: "1234"
    - `:sender_account_type` [string]: sender's bank account type. Options: "checking", "savings", "salary" or "payment"
    - `:sender_bank_code` [string]: sender's participant code (ISPB). ex: "20018183"
    - `:sender_tax_id` [string]: sender's tax ID (CPF/CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:receiver_account_number` [string]: receiver's bank account number. ex: "76543"
    - `:receiver_branch_code` [string]: receiver's bank account branch code. ex: "1234"
    - `:receiver_account_type` [string]: receiver's bank account type. Options: "checking", "savings", "salary" or "payment"
    - `:receiver_bank_code` [string]: receiver's participant code (ISPB). ex: "20018183"
    - `:receiver_tax_id` [string]: receiver's tax ID (CPF/CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"

  ## Parameters (optional):
    - `:receiver_key_id` [string, default nil]: receiver's Pix Key used in the reported transaction. ex: "+5511989898989"
    - `:return_id` [string, default nil]: central bank's unique reversal transaction id. Required when reference_type is "reversal". ex: "D20018183202201201213u34sav898j"

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the PixInternalTransactionReport is created. ex: "5656565656565656"
    - `:status` [string]: current PixInternalTransactionReport status. Options: "created", "processing", "success", "failed"
    - `:updated` [DateTime]: latest update datetime for the PixInternalTransactionReport. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :amount,
    :created,
    :end_to_end_id,
    :method,
    :reference_type,
    :sender_account_number,
    :sender_branch_code,
    :sender_account_type,
    :sender_bank_code,
    :sender_tax_id,
    :receiver_account_number,
    :receiver_branch_code,
    :receiver_account_type,
    :receiver_bank_code,
    :receiver_tax_id
  ]
  defstruct [
    :amount,
    :created,
    :end_to_end_id,
    :method,
    :reference_type,
    :sender_account_number,
    :sender_branch_code,
    :sender_account_type,
    :sender_bank_code,
    :sender_tax_id,
    :receiver_account_number,
    :receiver_branch_code,
    :receiver_account_type,
    :receiver_bank_code,
    :receiver_tax_id,
    :receiver_key_id,
    :return_id,
    :id,
    :status,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Create PixInternalTransactionReports in the Stark Infra API

  ## Parameters (required):
    - `:reports` [list of PixInternalTransactionReport]: list of PixInternalTransactionReport structs to be created in the API. You can send up to 100 PixInternalTransactionReport structs in a single request.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PixInternalTransactionReport structs with updated attributes
  """
  @spec create(
    reports: [PixInternalTransactionReport.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [PixInternalTransactionReport.t()]} |
    {:error, Error.t()}
  def create(reports, options \\ []) do
    Rest.post(
      resource(),
      reports,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    reports: [PixInternalTransactionReport.t() | map()],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(reports, options \\ []) do
    Rest.post!(
      resource(),
      reports,
      options
    )
  end

  @doc """
  Retrieve the PixInternalTransactionReport struct linked to your Workspace in the Stark Infra API using its id.

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656".

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixInternalTransactionReport struct that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, PixInternalTransactionReport.t()} |
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
  Receive a stream of PixInternalTransactionReports structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: ["created", "processing", "success", "failed"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixInternalTransactionReport structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [PixInternalTransactionReport.t()]} |
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
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 PixInternalTransactionReport structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your reports.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call.
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created after a specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created before a specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. Options: ["created", "processing", "success", "failed"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixInternalTransactionReport structs with updated attributes
    - cursor to retrieve the next page of PixInternalTransactionReport structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [PixInternalTransactionReport.t()]}} |
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
      "PixInternalTransactionReport",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %PixInternalTransactionReport{
      amount: json[:amount],
      created: json[:created] |> Check.date_or_datetime(),
      end_to_end_id: json[:end_to_end_id],
      method: json[:method],
      reference_type: json[:reference_type],
      sender_account_number: json[:sender_account_number],
      sender_branch_code: json[:sender_branch_code],
      sender_account_type: json[:sender_account_type],
      sender_bank_code: json[:sender_bank_code],
      sender_tax_id: json[:sender_tax_id],
      receiver_account_number: json[:receiver_account_number],
      receiver_branch_code: json[:receiver_branch_code],
      receiver_account_type: json[:receiver_account_type],
      receiver_bank_code: json[:receiver_bank_code],
      receiver_tax_id: json[:receiver_tax_id],
      receiver_key_id: json[:receiver_key_id],
      return_id: json[:return_id],
      id: json[:id],
      status: json[:status],
      updated: json[:updated] |> Check.datetime(),
    }
  end
end
