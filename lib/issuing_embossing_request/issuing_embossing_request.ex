defmodule StarkInfra.IssuingEmbossingRequest do
  alias __MODULE__, as: IssuingEmbossingRequest
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
    Groups IssuingEmbossingRequest related functions
  """

  @doc """
  The IssuingEmbossingRequest object displays the information of embossing requests in your Workspace.

  ## Parameters (required):
    - `:card_id` [binary]: id of the IssuingCard to be embossed. ex "5656565656565656"
    - `:kit_id` [binary]: card embossing kit id. ex "5656565656565656"
    - `:display_name_1` [binary]: card displayed name. ex: "ANTHONY STARK"
    - `:shipping_city` [binary]: shipping city. ex: "NEW YORK"
    - `:shipping_country_code` [binary]: shipping country code. ex: "US"
    - `:shipping_district` [binary]: shipping district. ex: "NY"
    - `:shipping_state_code` [binary]: shipping state code. ex: "NY"
    - `:shipping_street_line_1` [binary]: shipping main address. ex: "AVENUE OF THE AMERICAS"
    - `:shipping_street_line_2` [binary]: shipping address complement. ex: "Apt. 6"
    - `:shipping_service` [binary]: shipping service. ex: "loggi"
    - `:shipping_tracking_number` [binary]: shipping tracking number. ex: "5656565656565656"
    - `:shipping_zip_code` [binary]: shipping zip code. ex: "12345-678"

  ## Parameters (optional):
    - `:embosser_id` [binary, default nil]: id of the card embosser. ex: "5656565656565656"
    - `:display_name_2` [binary, default nil]: card displayed name. ex: "IT Services"
    - `:display_name_3` [binary, default nil]: card displayed name. ex: "StarkBank S.A."
    - `:shipping_phone` [binary, default nil]: shipping phone. ex: "+5511999999999"
    - `:tags` [list of binaries, default nil]: list of binaries for tagging. ex: ["card", "corporate"]

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when IssuingEmbossingRequest is created. ex: "5656565656565656"
    - `:fee` [integer]: fee charged when IssuingEmbossingRequest is created. ex: 1000
    - `:status` [binary]: status of the IssuingEmbossingRequest. ex: "created", "processing", "success", "failed"
    - `:updated` [DateTime]: latest update datetime for the IssuingEmbossingRequest.
    - `:created` [DateTime]: creation datetime for the IssuingEmbossingRequest.
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
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of IssuingEmbossingRequest objects for creation in the Stark Infra API.

  ## Parameters (required):
    - `:requests` [list of IssuingEmbossingRequest objects]: list of IssuingEmbossingRequest objects to be created in the API

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingEmbossingRequest objects with updated attributes
  """
  @spec create(
    [IssuingEmbossingRequest.t() | map],
    user: Organization.t() | Project.t() | nil
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
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(requests, options \\ []) do
    Rest.post!(
      resource(),
      requests,
      options
    )
  end

  @doc """
  Receive a stream of IssuingEmbossingRequest objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "success", "failed"]
    - `:card_ids` [list of binaries, default nil]: list of card_ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingEmbossingRequest objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    card_ids: [binary],
    tags: [binary],
    ids: [binary],
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, [IssuingEmbossingRequest.t()]} |
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
    status: binary,
    card_ids: [binary],
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
  Receive a list of IssuingEmbossingRequest previously created in the Stark Infra API and the cursor to the next page.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "success", "failed"]
    - `:card_ids` [list of binaries, default nil]: list of card_ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingEmbossingRequest objects with updated attributes
    - cursor to retrieve the next page of IssuingEmbossingRequest objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    card_ids: [binary],
    ids: [binary],
    tags: [binary],
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, {binary, [IssuingEmbossingRequest.t()]}} |
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
    status: [binary],
    card_ids: [binary],
    ids: [binary],
    tags: [binary],
    user: (Organization.t() | Project.t() | nil)
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Receive a single IssuingEmbossingRequest objects previously created in the Stark Infra API by its id.

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingEmbossingRequest objects that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, IssuingEmbossingRequest.t()} |
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
      updated: json[:updated],
      created: json[:created]
    }
  end
end
