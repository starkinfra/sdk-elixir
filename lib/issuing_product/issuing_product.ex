defmodule StarkInfra.IssuingProduct do
  alias __MODULE__, as: IssuingProduct
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IssuingProduct related functions
  """

  @doc """
  The IssuingProduct object displays information of registered card products to your Workspace.
  They represent a group of cards that begin with the same numbers (id) and offer the same product to end customers.

  ## Attributes (return-only):
    - `:id` [string]: unique card product number (BIN) registered within the card network. ex: "53810200"
    - `:network` [string]: card network flag. ex: "mastercard"
    - `:funding_type` [string]: type of funding used for payment. ex: "credit", "debit"
    - `:holder_type` [string]: holder type. ex: "business", "individual"
    - `:code` [string]: internal code from card flag informing the product. ex: "MRW", "MCO", "MWB", "MCS"
    - `:customer_type` [string]: same as holder_type. Kept for backward compatibility.
    - `:created` [DateTime]: creation datetime for the IssuingProduct. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :id,
    :network,
    :funding_type,
    :holder_type,
    :code,
    :created
  ]
  defstruct [
    :id,
    :network,
    :funding_type,
    :holder_type,
    :code,
    :customer_type,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of IssuingProduct structs previously registered in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingProduct structs with updated attributes
  """
  @spec query(
    limit: integer,
    user: Project.t() | Organization.t() | nil
  ) ::
    { :ok, [IssuingProduct.t()] } |
    { :error, [error: Error.t()] }
  def query(options \\ []) do
    Rest.get_list(resource(), options)
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
    limit: integer,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 IssuingProduct structs previously registered in the Stark Infra API and the cursor to the next page.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingProduct structs with updated attributes
    - cursor to retrieve the next page of IssuingProduct structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    user: Project.t() | Organization.t() | nil
  ) ::
    { :ok, {binary, [IssuingProduct.t()]}} |
    { :error, [error: Error.t()] }
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
    \Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
    cursor: binary,
    limit: integer,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "IssuingProduct",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingProduct{
      id: json[:id],
      network: json[:network],
      funding_type: json[:funding_type],
      holder_type: json[:holder_type],
      code: json[:code],
      customer_type: json[:customer_type],
      created: json[:created] |> Check.datetime()
    }
  end
end
