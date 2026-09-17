defmodule StarkInfra.IssuingEmbossingRequest do
  alias __MODULE__, as: IssuingEmbossingRequest
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IssuingEmbossingRequest related functions
  """

  @doc """
  The IssuingEmbossingRequest struct displays the information of embossing requests in your Workspace.
  When you initialize a IssuingEmbossingRequest, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the list of created structs.

  ## Parameters (required):
    - `:card_id` [string]: id of the IssuingCard to be embossed. ex "5656565656565656"
    - `:kit_id` [string]: card embossing kit id. ex "5656565656565656"
    - `:display_name_1` [string]: card displayed name. ex: "ANTHONY STARK"
    - `:shipping_city` [string]: shipping city. ex: "NEW YORK"
    - `:shipping_country_code` [string]: shipping country code. ex: "US"
    - `:shipping_district` [string]: shipping district. ex: "NY"
    - `:shipping_state_code` [string]: shipping state code. ex: "NY"
    - `:shipping_street_line_1` [string]: shipping main address. ex: "AVENUE OF THE AMERICAS"
    - `:shipping_street_line_2` [string]: shipping address complement. ex: "Apt. 6"
    - `:shipping_service` [string]: shipping service. ex: "loggi"
    - `:shipping_tracking_number` [string]: shipping tracking number. ex: "5656565656565656"
    - `:shipping_zip_code` [string]: shipping zip code. ex: "12345-678"

  ## Parameters (optional):
    - `:embosser_id` [string, default nil]: id of the card embosser. ex: "5656565656565656"
    - `:display_name_2` [string, default nil]: card displayed name. ex: "IT Services"
    - `:display_name_3` [string, default nil]: card displayed name. ex: "StarkBank S.A."
    - `:shipping_phone` [string, default nil]: shipping phone. ex: "+5511999999999"
    - `:tags` [list of strings, default nil]: list of strings for tagging. ex: ["card", "corporate"]

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when IssuingEmbossingRequest is created. ex: "5656565656565656"
    - `:fee` [integer, default nil]: fee charged when IssuingEmbossingRequest is created. ex: 1000
    - `:status` [string, default nil]: status of the IssuingEmbossingRequest. ex: "created", "processing", "success", "failed"
    - `:updated` [DateTime, default nil]: latest update datetime for the IssuingEmbossingRequest.
    - `:created` [DateTime, default nil]: creation datetime for the IssuingEmbossingRequest.
  """
  @enforce_keys [
    :card_id,
    :kit_id,
    :display_name_1,
    :shipping_city,
    :shipping_country_code,
    :shipping_district,
    :shipping_state_code,
    :shipping_street_line_1,
    :shipping_street_line_2,
    :shipping_service,
    :shipping_tracking_number,
    :shipping_zip_code
  ]
  defstruct [
    :card_id,
    :kit_id,
    :display_name_1,
    :shipping_city,
    :shipping_country_code,
    :shipping_district,
    :shipping_state_code,
    :shipping_street_line_1,
    :shipping_street_line_2,
    :shipping_service,
    :shipping_tracking_number,
    :shipping_zip_code,
    :embosser_id,
    :display_name_2,
    :display_name_3,
    :shipping_phone,
    :tags,
    :id,
    :fee,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of IssuingEmbossingRequest structs for creation in the Stark Infra API

  ## Parameters (required):
    - `:requests` [list of IssuingEmbossingRequest structs]: list of IssuingEmbossingRequest structs to be created in the API. You can send up to 100 structs in a single request.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingEmbossingRequest structs with updated attributes
  """
  @spec create(
    [IssuingEmbossingRequest.t() | map],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [IssuingEmbossingRequest.t()]} |
    {:error, [Error.t()]}
  def create(requests, options \\ []) do
    Rest.post(
      resource(),
      requests,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    [IssuingEmbossingRequest.t() | map],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(requests, options \\ []) do
    Rest.post!(
      resource(),
      requests,
      options
    )
  end

  @doc """
  Receive a single IssuingEmbossingRequest struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingEmbossingRequest struct with updated attributes
  """
  @spec get(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, IssuingEmbossingRequest.t()} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: IssuingEmbossingRequest.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of IssuingEmbossingRequest structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil] date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil] date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "processing", "success", "failed"]
    - `:card_ids` [list of strings, default nil]: list of card_ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingEmbossingRequest structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    card_ids: [binary],
    ids: [binary],
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, {:ok, [IssuingEmbossingRequest.t()]}} |
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
    status: [binary],
    card_ids: [binary],
    ids: [binary],
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, [IssuingEmbossingRequest.t()]} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 IssuingEmbossingRequest structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or string, default nil] date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil] date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "processing", "success", "failed"]
    - `:card_ids` [list of strings, default nil]: list of card_ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingEmbossingRequest structs with updated attributes
    - cursor to retrieve the next page of IssuingEmbossingRequest structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    card_ids: [binary],
    ids: [binary],
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [IssuingEmbossingRequest.t()]}} |
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
    status: [binary],
    card_ids: [binary],
    ids: [binary],
    tags: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    [IssuingEmbossingRequest.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "IssuingEmbossingRequest",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingEmbossingRequest{
      card_id: json[:card_id],
      kit_id: json[:kit_id],
      display_name_1: json[:display_name_1],
      shipping_city: json[:shipping_city],
      shipping_country_code: json[:shipping_country_code],
      shipping_district: json[:shipping_district],
      shipping_state_code: json[:shipping_state_code],
      shipping_street_line_1: json[:shipping_street_line_1],
      shipping_street_line_2: json[:shipping_street_line_2],
      shipping_service: json[:shipping_service],
      shipping_tracking_number: json[:shipping_tracking_number],
      shipping_zip_code: json[:shipping_zip_code],
      embosser_id: json[:embosser_id],
      display_name_2: json[:display_name_2],
      display_name_3: json[:display_name_3],
      shipping_phone: json[:shipping_phone],
      tags: json[:tags],
      id: json[:id],
      fee: json[:fee],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
