defmodule StarkInfra.CreditHolmes do
  alias __MODULE__, as: CreditHolmes
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups CreditHolmes related functions
  """

  @doc """
  CreditHolmes are used to obtain debt information on your customers.
  Before you create a CreditHolmes, make sure you have your customer's express
  authorization to verify their information in the Central Bank's SCR.
  When you initialize a CreditHolmes, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the list of created structs.

  ## Parameters (required):
    - `:tax_id` [string]: customer's tax ID (CPF or CNPJ) for whom the credit operations will be verified. ex: "20.018.183/0001-80"

  ## Parameters (optional):
    - `:competence` [string, default 'two months before current date']: competence month of the operation verification, format: "YYYY-MM". ex: "2021-04"
    - `:tags` [list of strings, default []]: list of strings for reference when searching for CreditHolmes. ex: ["credit", "operation"]

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when the CreditHolmes is created. ex: "5656565656565656"
    - `:result` [map, default nil]: result of the investigation after the case is solved.
    - `:status` [string, default nil]: current status of the CreditHolmes. ex: "created", "failed", "success"
    - `:created` [DateTime, default nil]: creation datetime for the CreditHolmes. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime, default nil]: latest update datetime for the CreditHolmes. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :tax_id
  ]
  defstruct [
    :tax_id,
    :competence,
    :tags,
    :id,
    :result,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of CreditHolmes structs for creation in the Stark Infra API

  ## Parameters (required):
    - `:holmes` [list of CreditHolmes structs]: list of CreditHolmes structs to be created in the API. You can send up to 100 CreditHolmes structs in a single request.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CreditHolmes structs with updated attributes
  """
  @spec create(
    [CreditHolmes.t() | map],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [CreditHolmes.t()]} |
    {:error, [Error.t()]}
  def create(holmes, options \\ []) do
    Rest.post(
      resource(),
      holmes,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    [CreditHolmes.t() | map],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(holmes, options \\ []) do
    Rest.post!(
      resource(),
      holmes,
      options
    )
  end

  @doc """
  Receive a single CreditHolmes struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct's unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CreditHolmes struct with updated attributes
  """
  @spec get(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, CreditHolmes.t()} |
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
  Receive a stream of CreditHolmes structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil] date filter for structs created only after specified date. ex: ~D[2020, 3, 10]
    - `:before` [Date or string, default nil] date filter for structs created only before specified date. ex: ~D[2020, 3, 10]
    - `:status` [string, default nil]: filter for status of retrieved structs. Options: "created", "failed", "success"
    - `:tags` [list of strings, default []]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default []]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CreditHolmes structs with updated attributes
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
    ({:cont, {:ok, [CreditHolmes.t()]}} |
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
    ({:cont, [CreditHolmes.t()]} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 CreditHolmes structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or string, default nil] date filter for structs created only after specified date. ex: ~D[2020-3-10]
    - `:before` [Date or string, default nil] date filter for structs created only before specified date. ex: ~D[2020-3-10]
    - `:status` [string, default nil]: filter for status of retrieved structs. Options: "created", "failed", "success"
    - `:tags` [list of strings, default []]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default []]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CreditHolmes structs with updated attributes
    - cursor to retrieve the next page of CreditHolmes structs
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
    {:ok, {binary, [CreditHolmes.t()]}} |
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
    [CreditHolmes.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "CreditHolmes",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %CreditHolmes{
      tax_id: json[:tax_id],
      competence: json[:competence],
      tags: json[:tags],
      id: json[:id],
      result: json[:result],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
