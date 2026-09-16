defmodule StarkInfra.IssuingBillingTransaction do
  alias __MODULE__, as: IssuingBillingTransaction
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IssuingBillingTransaction related functions
  """

  @doc """
  The IssuingBillingTransaction structs are used to display each debit or credit that composes an
  IssuingBillingInvoice charged from your Workspace to cover the costs of your Issuing operations.

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the IssuingBillingTransaction is created. ex: "5656565656565656"
    - `:amount` [integer]: IssuingBillingTransaction value in cents. Positive for credits, negative for debits. ex: 1234 (= R$ 12.34)
    - `:invoice_id` [string]: unique id of the IssuingBillingInvoice to which this IssuingBillingTransaction belongs. ex: "5656565656565656"
    - `:installment` [integer]: installment number of the charged operation. ex: 1
    - `:installment_count` [integer]: total number of installments of the charged operation. ex: 12
    - `:balance` [integer]: balance amount of the Workspace at the instant of the IssuingBillingTransaction in cents. ex: 200 (= R$ 2.00)
    - `:holder_name` [string]: card holder name related to the charged operation. ex: "Tony Stark"
    - `:source` [string]: source of the IssuingBillingTransaction. ex: "issuing-purchase/5656565656565656"
    - `:external_id` [string]: external id of the charged operation. ex: "my-internal-id-123456"
    - `:description` [string]: IssuingBillingTransaction description. ex: "Buying food"
    - `:card_ending` [string]: last 4 digits of the card used in the charged operation. ex: "1234"
    - `:tax` [integer]: tax amount charged over the operation in cents. ex: 100
    - `:rate` [float]: exchange rate applied to the charged operation. ex: 5.29
    - `:merchant_amount` [integer]: original amount charged by the merchant in its own currency, in cents. ex: 1234 (= R$ 12.34)
    - `:merchant_currency_code` [string]: merchant currency code. ex: "USD"
    - `:created` [DateTime]: creation datetime for the IssuingBillingTransaction. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :id,
    :amount,
    :invoice_id,
    :installment,
    :installment_count,
    :balance,
    :holder_name,
    :source,
    :external_id,
    :description,
    :card_ending,
    :tax,
    :rate,
    :merchant_amount,
    :merchant_currency_code,
    :created
  ]
  defstruct [
    :id,
    :amount,
    :invoice_id,
    :installment,
    :installment_count,
    :balance,
    :holder_name,
    :source,
    :external_id,
    :description,
    :card_ending,
    :tax,
    :rate,
    :merchant_amount,
    :merchant_currency_code,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of IssuingBillingTransaction structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [DateTime or string, default nil] date filter for structs created only after specified date. ex: ~U[2020-3-10 10:30:0:0]
    - `:before` [DateTime or string, default nil] date filter for structs created only before specified date. ex: ~U[2020-3-10 10:30:0:0]
    - `:invoice_id` [string, default nil]: filter for the IssuingBillingInvoice id to which the retrieved IssuingBillingTransactions belong. ex: "5656565656565656"
    - `:tags` [list of strings, default []]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingBillingTransaction structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: DateTime.t() | binary,
    before: DateTime.t() | binary,
    invoice_id: binary,
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, {:ok, [IssuingBillingTransaction.t()]}} |
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
    invoice_id: binary,
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, [IssuingBillingTransaction.t()]} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 IssuingBillingTransaction structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [DateTime or string, default nil] date filter for structs created only after specified date. ex: ~U[2020-3-10 10:30:0:0]
    - `:before` [DateTime or string, default nil] date filter for structs created only before specified date. ex: ~U[2020-3-10 10:30:0:0]
    - `:invoice_id` [string, default nil]: filter for the IssuingBillingInvoice id to which the retrieved IssuingBillingTransactions belong. ex: "5656565656565656"
    - `:tags` [list of strings, default []]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingBillingTransaction structs with updated attributes
    - cursor to retrieve the next page of IssuingBillingTransaction structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: DateTime.t() | binary,
    before: DateTime.t() | binary,
    invoice_id: binary,
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [IssuingBillingTransaction.t()]}} |
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
    invoice_id: binary,
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    [IssuingBillingTransaction.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "IssuingBillingTransaction",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingBillingTransaction{
      id: json[:id],
      amount: json[:amount],
      invoice_id: json[:invoice_id],
      installment: json[:installment],
      installment_count: json[:installment_count],
      balance: json[:balance],
      holder_name: json[:holder_name],
      source: json[:source],
      external_id: json[:external_id],
      description: json[:description],
      card_ending: json[:card_ending],
      tax: json[:tax],
      rate: json[:rate],
      merchant_amount: json[:merchant_amount],
      merchant_currency_code: json[:merchant_currency_code],
      created: json[:created] |> Check.datetime()
    }
  end
end
