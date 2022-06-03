defmodule StarkInfra.IssuingHolder do
  alias __MODULE__, as: IssuingHolder
  alias StarkInfra.IssuingRule
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
    Groups IssuingHolder related functions
  """

  @doc """
  The IssuingHolder describes a card holder that may group several cards.

  ## Parameters (required):
    - `:name` [binary]: card holder's name.
    - `:tax_id` [binary]: card holder's tax ID
    - `:external_id` [binary] card holder's external ID

  ## Parameters (optional):
    - `:rules` [list of IssuingRule structs, default []]: [EXPANDABLE] list of holder spending rules
    - `:tags` [list of binarys, default []]: list of binarys for tagging. ex: ["travel", "food"]

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when IssuingHolder is created. ex: "5656565656565656"
    - `:status` [binary]: current IssuingHolder status. ex: "active", "blocked" or "canceled"
    - `:updated` [DateTime]: latest update DateTime for the IssuingHolder. ex: ~U[2020-3-10 10:30:0:0]
    - `:created` [DateTime]: creation datetime for the IssuingHolder. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :name,
    :tax_id,
    :external_id
  ]
  defstruct [
    :id,
    :status,
    :updated,
    :created,
    :name,
    :tax_id,
    :external_id,
    :rules,
    :tags
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of IssuingHolder structs for creation in the Stark Infra API.

  ## Parameters (required):
    - `:holders` [list of IssuingHolder structs]: list of IssuingHolder structs to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingHolder structs with updated attributes
  """
  @spec create(
    holders: [IssuingHolder.t()],
    user: Project.t() | Organization.t() | nil
  ) ::
    { :ok, [IssuingHolder.t()] } |
    { :error, [error: Error.t()] }
  def create(holders, options \\ []) do
    Rest.post(resource(), holders, options)
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    holders: [IssuingHolder.t()],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(holders, options \\ []) do
    Rest.post!(resource(), holders, options)
  end

  @doc """
  Receive a single IssuingHolder struct previously created in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [binary]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:expand` [list of binarys, default nil]: fields to expand information. ex: ["rules"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingHolder struct with updated attributes
  """
  @spec get(
    id: binary,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    { :ok, [IssuingHolder.t()] } |
    { :error, [error: Error.t()] }
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(
    id: binary,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of IssuingHolder structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [binary, default nil]: filter for status of retrieved structs. ex: "paid" or "registered"
    - `:tags` [list of binarys, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of binarys, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:expand` [list of binarys, default nil]: fields to expand information. ex: ["rules"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingHolder structs with updated attributes
  """
  @spec query(
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: binary | nil,
    tags: [binary] | nil,
    ids: [binary] | nil,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    { :cont, [IssuingHolder.t()] } |
    { :error, [error: Error.t()] }
  def query(options \\ []) do
    Rest.get_list(resource(), options)
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: binary | nil,
    tags: [binary] | nil,
    ids: [binary] | nil,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of IssuingHolder structs previously created in the Stark Infra API and the cursor to the next page.

  ## Options:
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "paid" or "registered"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:expand` [string, default nil]: fields to expand information. ex: "rules, securityCode, number, expiration"
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingHolder structs with updated attributes
    - cursor to retrieve the next page of IssuingHolder structs
  """
  @spec page(
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: binary | nil,
    tags: [binary] | nil,
    ids: [binary] | nil,
    expand: [binary] | nil,
    cursor: binary | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    { :cont, {binary, [IssuingHolder.t()] }} |
    { :error, [error: Error.t()] }
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: binary | nil,
    tags: [binary] | nil,
    ids: [binary] | nil,
    expand: [binary] | nil,
    cursor: binary | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Update an IssuingHolder by passing id, if it hasn't been paid yet.

  ## Parameters (required):
    - `:id` [string]: IssuingHolder id. ex: '5656565656565656'

  ## Parameters (optional):
    - `:status` [string, default nil]: You may block the IssuingHolder by passing 'blocked' in the status.
    - `:name` [string, default nil]: card holder name.
    - `:tags` [list of strings, default nil]: list of strings for tagging.
    - `:rules` [list of dictionaries, default nil]: list of dictionaries with "amount": int, "currencyCode": string, "id": string, "interval": string, "name": string pairs
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target IssuingHolder with updated attributes
  """
  @spec update(
    id: binary,
    status: binary | nil,
    name: binary | nil,
    tags: [binary] | nil,
    rules: [IssuingRule.t()] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    { :ok, IssuingHolder.t() } |
    { :error, [error: Error.t()] }
  def update(id, parameters \\ []) do
    Rest.patch_id(resource(), id, parameters)
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(
    id: binary,
    status: binary | nil,
    name: binary | nil,
    tags: [binary] | nil,
    rules: [IssuingRule.t()] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def update!(id, parameters \\ []) do
    Rest.patch_id!(resource(), id, parameters)
  end

  @doc """
  Cancel an IssuingHolder entity previously created in the Stark Infra API.

  ## Parameters (required):
    - `:id` [string]: IssuingHolder unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled IssuingHolder struct
  """
  @spec cancel(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    { :ok, IssuingHolder.t() } |
    { :error, [error: Error.t()] }
  def cancel(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as cancel(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec cancel!(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def cancel!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
  end

  @doc false
  def resource() do
    {
      "IssuingHolder",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingHolder{
      id: json[:id],
      status: json[:status],
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime(),
      name: json[:name],
      tax_id: json[:tax_id],
      external_id: json[:external_id],
      rules: json[:rules] |> Enum.map(fn rule -> API.from_api_json(rule, &IssuingRule.resource_maker/1) end),
      tags: json[:tags]
    }
  end
end
