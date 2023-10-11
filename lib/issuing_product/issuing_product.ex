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
  The IssuingProduct object displays information of available card products registered to your Workspace.
  They represent a group of cards that begin with the same numbers (id) and offer the same product to end customers.

  ## Attributes (return-only):
    - `:id` [binary]: unique card product number (BIN) registered within the card network. ex: "53810200"
    - `:network` [binary]: card network flag. ex: "mastercard"
    - `:funding_type` [binary]: type of funding used for payment. ex: "credit", "debit"
    - `:holder_type` [binary]: holder type. ex: "business", "individual"
    - `:code` [binary]: internal code from card flag informing the product. ex: "MRW", "MCO", "MWB", "MCS"
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
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of IssuingProduct objects previously registered in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingProduct objects with updated attributes
  """
  @spec query(
    limit: integer,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [IssuingProduct.t()] } |
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
  Receive a list of up to 100 IssuingProduct objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingProduct objects with updated attributes
    - cursor to retrieve the next page of IssuingProduct objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [IssuingProduct.t()]}} |
    { :error, [error: Error.t()] }
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
    Same as page(), but it will unwrap the error tuple and raise in case of errors.
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
      created: json[:created] |> Check.datetime()
    }
  end
end
