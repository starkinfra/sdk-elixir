defmodule StarkInfra.CreditHolmes do
  alias __MODULE__, as: CreditHolmes
  alias StarkInfra.Utils.Rest
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
  created in the Stark Infra API. The 'create' function sends the objects
  to the Stark Infra API and returns the list of created objects.

  ## Parameters (required):
    - `:tax_id` [binary]: customer's tax ID (CPF or CNPJ) for whom the credit operations will be verified. ex: "20.018.183/0001-80"

  ## Parameters (optional):
    - `:competence` [binary, default 'two months before current date']: competence month of the operation verification, format: "YYYY-MM". ex: "2021-04"
    - `:tags` [list of binaries, default []]: list of binaries for reference when searching for CreditHolmes. ex: [credit", "operation"]

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when CreditHolmes is created. ex: "5656565656565656"
    - `:result` [binary]: result of the investigation after the case is solved.
    - `:status` [binary]: current status of the CreditHolmes. ex: "created", "failed", "success"
    - `:updated` [DateTime]: latest update DateTime for the CreditHolmes. ex: ~U[2020-3-10 10:30:0:0]
    - `:created` [DateTime]: creation datetime for the CreditHolmes. ex: ~U[2020-03-10 10:30:0:0]
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
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of CreditHolmes objects for creation in the Stark Infra API.

  ## Parameters (required):
    - `:holmes` [list of CreditHolmes objects]: list of CreditHolmes objects to be created in the API

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CreditHolmes objects with updated attributes
  """
  @spec create(
    [CreditHolmes.t() | map],
    user: Organization.t() | Project.t() | nil
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
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(holmes, options \\ []) do
    Rest.post!(
      resource(),
      holmes,
      options
    )
  end

  @doc """
  Receive a stream of CreditHolmes objects previously created in the Stark Infra API.

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:status` [binary, default nil]: filter for status of retrieved objects. ex: "created", "failed", "success"
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CreditHolmes objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    tags: [binary],
    ids: [binary],
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, [CreditHolmes.t()]} |
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
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    tags: [binary],
    ids: [binary],
    user: (Organization.t() | Project.t() | nil)
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 CreditHolmes objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:status` [binary, default nil]: filter for status of retrieved objects. ex: "created", "failed", "success"
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CreditHolmes objects with updated attributes
    - cursor to retrieve the next page of CreditHolmes objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    tags: [binary],
    ids: [binary],
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, {binary, [CreditHolmes.t()]}} |
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
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    tags: [binary],
    ids: [binary],
    user: (Organization.t() | Project.t() | nil)
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Receive a single CreditHolmes object previously created in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CreditHolmes object with updated attributes
  """
  @spec get(
    id: binary,
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, CreditHolmes.t()} |
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
    user: (Organization.t() | Project.t() | nil)
  ) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(
      resource(),
      id,
      options
    )
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
      id: json[:id],
      tax_id: json[:tax_id],
      competence: json[:competence],
      tags: json[:tags],
      result: json[:result],
      status: json[:status],
      updated: json[:updated],
      created: json[:created]
    }
  end
end
