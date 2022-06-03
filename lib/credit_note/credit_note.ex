defmodule StarkInfra.CreditNote do
  alias __MODULE__, as: CreditNote
  alias StarkInfra.Error
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.CreditNote.Signer
  alias StarkInfra.CreditNote.Invoice
  alias StarkInfra.CreditNote.Transfer

  @moduledoc """
  Groups CreditNote related functions
  """

  @doc """
  CreditNotes are used to generate CCB contracts between you and your customers.
  When you initialize a CreditNote, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the list of created structs.

  ## Parameters (required):
    - `:template_id` [string]: ID of the contract template on which the CreditNote will be based. ex: "0123456789101112"
    - `:name` [string]: credit receiver's full name. ex: "Anthony Edward Stark"
    - `:tax_id` [string]: credit receiver's tax ID (CPF or CNPJ). ex: "20.018.183/0001-80"
    - `:nominal_amount` [integer]: amount in cents transferred to the credit receiver, before deductions. ex: 11234 (= R$ 112.34)
    - `:scheduled` [Date Datetime or string]: Date or datetime of transfer execution. ex: ~D[2020-03-10]
    - `:invoices` [list of Invoice structs or maps]: list of Invoice structs to be created and sent to the credit receiver. ex: [%{ due: "2023-06-25", amount: 120000, fine: 10, interest: 2}]
    - `:payment` [Transfer struct or map]: payment entity to be created and sent to the credit receiver. ex: %{ bankCode: "00000000", branchCode: "1234", accountNumber: "129340-1", name: "Jamie Lannister", taxId: "012.345.678-90"}
    - `:signers` [list of Signer objects or maps]: name and e-mail of signers that sign the contract. ex: [%{"name": "Tony Stark", "contact": "tony@starkindustries.com", "method": "link"}]
    - `:external_id` [string]: a string that must be unique among all your CreditNotes, used to avoid resource duplication. ex: “my-internal-id-123456”
    - `:street_line_1` [string]: credit receiver main address. ex: "Av. Paulista, 200"
    - `:street_line_2` [string]: credit receiver address complement. ex: "Apto. 123"
    - `:district` [string]: credit receiver address district / neighbourhood. ex: "Bela Vista"
    - `:city` [string]: credit receiver address city. ex: "Rio de Janeiro"
    - `:state_code` [string]: credit receiver address state. ex: "GO"
    - `:zip_code` [string]: credit receiver address zip code. ex: "01311-200"

  ## Parameters (conditionally required):
    - `:payment_type` [string]: payment type, inferred from the payment parameter if it is not a dictionary. ex: "transfer"

  ## Parameters (optional):
    - `:rebate_amount` [integer, default 0]: credit analysis fee deducted from lent amount. ex: 11234 (= R$ 112.34)
    - `:tags` [list of strings, default []]: list of strings for reference when searching for CreditNotes. ex: [\"employees\", \"monthly\"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the CreditNote is created. ex: "5656565656565656"
    - `:amount` [integer]: CreditNote value in cents. ex: 1234 (= R$ 12.34)
    - `:expiration` [integer]: time interval in seconds between due date and expiration date. ex 123456789
    - `:document_id` [string]: ID of the signed document to execute this CreditNote. ex: "4545454545454545"
    - `:status` [string]: current status of the CreditNote. ex: "canceled", "created", "expired", "failed", "processing", "signed", "success"
    - `:transaction_ids` [list of strings]: ledger transaction ids linked to this CreditNote. ex: [\"19827356981273\"]
    - `:workspace_id` [string]: ID of the Workspace that generated this CreditNote. ex: "4545454545454545"
    - `:tax_amount` [integer]: tax amount included in the CreditNote. ex: 100
    - `:interest` [float]: yearly effective interest rate of the CreditNote, in percentage. ex: 12.5
    - `:created` [DateTime]: creation DateTime for the CreditNote. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update DateTime for the CreditNote. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :template_id,
    :name,
    :tax_id,
    :nominal_amount,
    :scheduled,
    :invoices,
    :payment,
    :signers,
    :external_id,
    :street_line_1,
    :street_line_2,
    :district,
    :city,
    :state_code,
    :zip_code,
  ]
  defstruct [
    :template_id,
    :name,
    :tax_id,
    :nominal_amount,
    :scheduled,
    :invoices,
    :payment,
    :signers,
    :external_id,
    :street_line_1,
    :street_line_2,
    :district,
    :city,
    :state_code,
    :zip_code,
    :payment_type,
    :rebate_amount,
    :tags,
    :id,
    :interest,
    :amount,
    :expiration,
    :document_id,
    :status,
    :transaction_ids,
    :workspace_id,
    :tax_amount,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of CreditNote structs for creation in the Stark Infra API

  ## Parameters (required):
    - `:notes` [list of CreditNote structs]: list of CreditNote structs to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CreditNote structs with updated attributes
  """
  @spec create(
    [CreditNote.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) ::
    { :ok, [CreditNote.t()]} |
    {:error, [Error.t()]}
  def create(notes, options \\ []) do
    Rest.post(
      resource(),
      notes,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create(
    [CreditNote.t() | map()],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(notes, options \\ []) do
    Rest.post!(
      resource(),
      notes,
      options
    )
  end

  @doc """
  Receive a single CreditNote struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct's unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CreditNote struct with updated attributes
  """
  @spec get(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [CreditNote.t()]} |
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
  Receive a stream of CreditNote structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil] date filter for structs created only after specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or string, default nil] date filter for structs created only before specified date. ex: ~D[2020, 3, 10]
    - `:status` [string, default nil]: filter for status of retrieved structs. Options: “canceled”, “created”, “expired”, “failed”, “processing”, “signed”, “success”.
    - `:tags` [list of strings, default []]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default []]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CreditNote structs with updated attributes
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
    ({:cont, {:ok, [CreditNote.t()]}} |
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
    ({:cont, [CreditNote.t()]} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 CreditNote structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or string, default nil] Date filter for structs created only after specified date. ex: ~D[2020-3-10]
    - `:before` [Date or string, default nil] Date filter for structs created only before specified date. ex: ~D(2020-3-10]
    - `:status` [string, default nil]: filter for status of retrieved structs. Options: “canceled”, “created”, “expired”, “failed”, “processing”, “signed”, “success”.
    - `:tags` [list of strings, default []]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default []]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CreditNote structs with updated attributes
    - cursor to retrieve the next page of CreditNote structs
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
    {:ok, {binary, [CreditNote.t()]}} |
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
    [CreditNote.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Cancel a CreditNote entity previously created in the Stark Infra API

  ## Parameters (required):
    - `:id` [string]: id of the CreditNote to be canceled

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled CreditNote struct
  """
  @spec cancel(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, CreditNote.t()} |
    {:error, [Error.t()]}
  def cancel(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as cancel(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec cancel!(
    binary,
    user: Project.t() | Organization.t() | nil
  ) :: CreditNote.t()
  def cancel!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
  end

  defp parse_payment!(payment, payment_type) do
    case payment_type do
      "transfer" -> API.from_api_json(payment, &Transfer.resource_maker/1)
      _ -> payment
    end
  end

  @doc false
  def resource() do
    {
      "CreditNote",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %CreditNote{
      template_id: json[:template_id],
      name: json[:name],
      tax_id: json[:tax_id],
      nominal_amount: json[:nominal_amount],
      scheduled: json[:scheduled],
      invoices: json[:invoices] |> Enum.map(fn invoice -> API.from_api_json(invoice, &Invoice.resource_maker/1) end),
      signers: json[:signers] |> Enum.map(fn signer -> API.from_api_json(signer, &Signer.resource_maker/1) end),
      payment: parse_payment!(json[:payment], json[:payment_type]),
      payment_type: json[:payment_type],
      external_id: json[:external_id],
      street_line_1: json[:street_line_1],
      street_line_2: json[:street_line_2],
      district: json[:district],
      city: json[:city],
      state_code: json[:state_code],
      zip_code: json[:zip_code],
      interest: json[:interest],
      rebate_amount: json[:rebate_amount],
      tags: json[:tags],
      created: json[:created] |> Check.datetime(),
      updated:  json[:updated] |> Check.datetime(),
      id: json[:id]
    }
  end
end
