defmodule StarkInfra.IssuingInvoice do
  alias __MODULE__, as: IssuingInvoice
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
    # IssuingInvoice object
  """

  @doc """
  The IssuingInvoice objects created in your Workspace load your Issuing balance when paid.

  ## Parameters (required):
    - `:amount` [integer]: IssuingInvoice value in cents. ex: 1234 (= R$ 12.34)

  ## Parameters (optional):
    - `:tax_id` [binary, default sub-issuer tax ID]: payer tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:name` [binary, default sub-issuer name]: payer name. ex: "Iron Bank S.A."
    - `:tags` [list of binaries, default []]: list of binaries for tagging. ex: ["travel", "food"]

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when IssuingInvoice is created. ex: "5656565656565656"
    - `:brcode` [binary]: BR Code for the Invoice payment. ex: "00020101021226930014br.gov.bcb.pix2571brcode-h.development.starkinfra.com/v2/d7f6546e194d4c64a153e8f79f1c41ac5204000053039865802BR5925Stark Bank S.A. - Institu6009Sao Paulo62070503***63042109"
    - `:due` [Date, DateTime or binary]: Invoice due and expiration date in UTC ISO format. ex: "2020-10-28T17:59:26.249976+00:00"
    - `:link` [binary]: public Invoice webpage URL. ex: "https://starkbank-card-issuer.development.starkbank.com/invoicelink/d7f6546e194d4c64a153e8f79f1c41ac"
    - `:status` [binary]: current IssuingInvoice status. Options: "created", "expired", "overdue", "paid"
    - `:issuing_transaction_id` [binary]: ledger transaction ids linked to this IssuingInvoice. ex: "issuing-invoice/5656565656565656"
    - `:updated` [DateTime]: latest update DateTime for the IssuingInvoice. ex: ~U[2020-3-10 10:30:0:0]
    - `:created` [DateTime]: creation datetime for the IssuingInvoice. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :amount
  ]
  defstruct [
    :amount,
    :tax_id,
    :name,
    :tags,
    :id,
    :brcode,
    :due,
    :link,
    :status,
    :issuing_transaction_id,
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of IssuingInvoice objects for creation in the Stark Infra API

  ## Parameters (required):
    - `:invoice` [IssuingInvoice object]: IssuingInvoice object to be created in the API.

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingInvoice object with updated attributes
  """
  @spec create(
    invoice: IssuingInvoice.t(),
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IssuingInvoice.t()} |
    {:error, [Error.t()]}
  def create(invoice, options \\ []) do
    Rest.post_single(
      resource(),
      invoice,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    invoice: IssuingInvoice.t(),
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(invoice, options \\ []) do
    Rest.post_single!(
      resource(),
      invoice,
      options
    )
  end

  @doc """
  Receive a single IssuingInvoice object previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingInvoice object that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IssuingInvoice.t()} |
    {:error, [Error.t()]}
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
  Receive a stream of IssuingInvoice objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["created", "expired", "overdue", "paid"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingInvoice objects with updated attributes
  """
  @spec query(
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: [binary] | nil,
    tags: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IssuingInvoice.t()]}} |
    {:error, [Error.t()]}
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
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: [binary] | nil,
    tags: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 IssuingInvoice objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["created", "expired", "overdue", "paid"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingInvoice objects with updated attributes
    - cursor to retrieve the next page of IssuingInvoice objects
  """
  @spec page(
    cursor: binary | nil,
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: [binary] | nil,
    tags: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IssuingInvoice.t()]}} |
    {:error, [Error.t()]}
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
    cursor: binary | nil,
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: [binary] | nil,
    tags: [binary] | nil,
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
      "IssuingInvoice",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingInvoice{
      amount: json[:amount],
      tax_id: json[:tax_id],
      name: json[:name],
      tags: json[:tags],
      id: json[:id],
      brcode: json[:brcode],
      due: json[:due],
      link: json[:link],
      status: json[:status],
      issuing_transaction_id: json[:issuing_transaction_id],
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime()
    }
  end
end
