defmodule StarkInfra.IssuingBillingInvoice do
  alias __MODULE__, as: IssuingBillingInvoice
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IssuingBillingInvoice related functions
  """

  @doc """
  The IssuingBillingInvoice structs are used to display the amounts charged from your Workspace to
  cover the costs of your Issuing operations, according to your Issuing billing plan.

  ## Attributes (return-only):
    - `:tax_id` [string]: payer tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:name` [string]: payer name. ex: "Iron Bank S.A."
    - `:fine` [float]: percentage charged if this IssuingBillingInvoice is paid after the due date. ex: 2.5
    - `:interest` [float]: interest percentage charged if this IssuingBillingInvoice is paid after the due date. ex: 1.5
    - `:status` [string]: current IssuingBillingInvoice status. ex: "created", "pending", "overdue", "expired", "paid"
    - `:amount` [integer]: IssuingBillingInvoice value in cents. ex: 1234 (= R$ 12.34)
    - `:nominal_amount` [integer]: IssuingBillingInvoice value before discounts and fees in cents. ex: 1234 (= R$ 12.34)
    - `:brcode` [string]: Pix brcode string for payment. ex: "00020101021226800014br.gov.bcb.pix2558invoice.starkbank.com/f5333103-3279-4db2-8389-5efe335ba93d5204000053039865802BR5913Arya Stark6009Sao Paulo6220051656565656565656566304A9A0"
    - `:link` [string]: public URL to the invoice payment page. ex: "https://my-workspace.sandbox.starkbank.com/invoicelink/d454fa4e524441c1b0c1a729457ed9d8"
    - `:due` [DateTime]: invoice due datetime. ex: ~U[2020-3-10 10:30:0:0]
    - `:start` [DateTime]: billing period start datetime. ex: ~U[2020-3-10 10:30:0:0]
    - `:end` [DateTime]: billing period end datetime. ex: ~U[2020-3-10 10:30:0:0]
    - `:id` [string]: unique id returned when the IssuingBillingInvoice is created. ex: "5656565656565656"
    - `:created` [DateTime]: creation datetime for the IssuingBillingInvoice. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the IssuingBillingInvoice. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :tax_id,
    :name,
    :fine,
    :interest,
    :status,
    :amount,
    :nominal_amount,
    :brcode,
    :link,
    :due,
    :start,
    :end,
    :id,
    :created,
    :updated
  ]
  defstruct [
    :tax_id,
    :name,
    :fine,
    :interest,
    :status,
    :amount,
    :nominal_amount,
    :brcode,
    :link,
    :due,
    :start,
    :end,
    :id,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single IssuingBillingInvoice struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingBillingInvoice struct with updated attributes
  """
  @spec get(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, IssuingBillingInvoice.t()} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: IssuingBillingInvoice.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of IssuingBillingInvoice structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [DateTime or string, default nil] date filter for structs created only after specified date. ex: ~U[2020-3-10 10:30:0:0]
    - `:before` [DateTime or string, default nil] date filter for structs created only before specified date. ex: ~U[2020-3-10 10:30:0:0]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "created", "pending", "overdue", "expired", "paid"
    - `:id` [string, default nil]: filter for the IssuingBillingInvoice id. ex: "5656565656565656"
    - `:tags` [list of strings, default []]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingBillingInvoice structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: DateTime.t() | binary,
    before: DateTime.t() | binary,
    status: binary,
    id: binary,
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, {:ok, [IssuingBillingInvoice.t()]}} |
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
    after: DateTime.t() | binary,
    before: DateTime.t() | binary,
    status: binary,
    id: binary,
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, [IssuingBillingInvoice.t()]} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 IssuingBillingInvoice structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [DateTime or string, default nil] date filter for structs created only after specified date. ex: ~U[2020-3-10 10:30:0:0]
    - `:before` [DateTime or string, default nil] date filter for structs created only before specified date. ex: ~U[2020-3-10 10:30:0:0]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "created", "pending", "overdue", "expired", "paid"
    - `:tags` [list of strings, default []]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingBillingInvoice structs with updated attributes
    - cursor to retrieve the next page of IssuingBillingInvoice structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: DateTime.t() | binary,
    before: DateTime.t() | binary,
    status: binary,
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [IssuingBillingInvoice.t()]}} |
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
    after: DateTime.t() | binary,
    before: DateTime.t() | binary,
    status: binary,
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    [IssuingBillingInvoice.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "IssuingBillingInvoice",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingBillingInvoice{
      tax_id: json[:tax_id],
      name: json[:name],
      fine: json[:fine],
      interest: json[:interest],
      status: json[:status],
      amount: json[:amount],
      nominal_amount: json[:nominal_amount],
      brcode: json[:brcode],
      link: json[:link],
      due: json[:due] |> Check.datetime(),
      start: json[:start] |> Check.datetime(),
      end: json[:end] |> Check.datetime(),
      id: json[:id],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
