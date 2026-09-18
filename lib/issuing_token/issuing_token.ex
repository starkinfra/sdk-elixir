defmodule StarkInfra.IssuingToken do
  alias __MODULE__, as: IssuingToken
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.Parse
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.JSON
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IssuingToken related functions
  """

  @doc """
  The IssuingToken struct displays the information of the tokens created in your Workspace.
  Tokens are tokenized versions of an IssuingCard stored in a digital wallet, so they are
  created through the wallet provisioning flow and can only be read, updated and canceled
  through this struct.

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the IssuingToken is created. ex: "5656565656565656"
    - `:card_id` [string]: id of the IssuingCard this token is associated with. ex: "5656565656565656"
    - `:wallet_id` [string]: id of the digital wallet where the token is stored. ex: "google"
    - `:wallet_name` [string]: name of the digital wallet. ex: "Apple Pay", "Google Pay"
    - `:merchant_id` [string]: id of the merchant if the token is merchant-specific. ex: "5656565656565656"
    - `:external_id` [string]: unique external identifier of the token. ex: "DSHRMC00002626944b0e3b539d4d459281bdba90c2588791"
    - `:wallet_device_score` [float]: device score informed by the digital wallet.
    - `:wallet_account_score` [float]: account score informed by the digital wallet.
    - `:status` [string]: current IssuingToken status. Options: "active", "blocked", "canceled", "frozen", "pending", "denied"
    - `:tags` [list of strings]: tags associated with the token. ex: ["employees", "monthly"]
    - `:created` [DateTime]: creation datetime for the IssuingToken. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the IssuingToken. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :id,
    :card_id,
    :wallet_id,
    :wallet_name,
    :merchant_id,
    :external_id,
    :wallet_device_score,
    :wallet_account_score,
    :status,
    :tags,
    :created,
    :updated
  ]
  defstruct [
    :id,
    :card_id,
    :wallet_id,
    :wallet_name,
    :merchant_id,
    :external_id,
    :wallet_device_score,
    :wallet_account_score,
    :status,
    :tags,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single IssuingToken struct previously created in the Stark Infra API by its id

  ## Parameters (required):
    - `:id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingToken struct with updated attributes
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IssuingToken.t()} |
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
  Receive a stream of IssuingToken structs previously created in the Stark Infra API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:status` [string, default nil]: current IssuingToken status. Options: "active", "blocked", "canceled", "frozen", "pending", "denied"
    - `:card_ids` [list of strings, default nil]: list of card_ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of strings, default nil]: list of strings for tagging. ex: ["travel", "food"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:external_ids` [list of strings, default nil]: list of external ids to filter retrieved structs. ex: ["DSHRMC00002626944b0e3b539d4d459281bdba90c2588791"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of IssuingToken structs with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    card_ids: [binary],
    tags: [binary],
    ids: [binary],
    external_ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [IssuingToken.t()]} |
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
    external_ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 IssuingToken structs previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:status` [string, default nil]: current IssuingToken status. Options: "active", "blocked", "canceled", "frozen", "pending", "denied"
    - `:card_ids` [list of strings, default nil]: list of card_ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of strings, default nil]: list of strings for tagging. ex: ["travel", "food"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:external_ids` [list of strings, default nil]: list of external ids to filter retrieved structs. ex: ["DSHRMC00002626944b0e3b539d4d459281bdba90c2588791"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of IssuingToken structs with updated attributes
    - cursor to retrieve the next page of IssuingToken structs
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: binary,
    card_ids: [binary],
    tags: [binary],
    ids: [binary],
    external_ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [IssuingToken.t()]}} |
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
    card_ids: [binary],
    tags: [binary],
    ids: [binary],
    external_ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Update an IssuingToken by passing its id.

  ## Parameters (required):
    - `:id` [string]: IssuingToken id. ex: "5656565656565656"

  ## Options:
    - `:status` [string, default nil]: you may block the IssuingToken by passing "blocked" or activate by passing "active". Options: "active", "blocked"
    - `:tags` [list of strings, default nil]: list of strings for tagging. ex: ["travel", "food"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target IssuingToken with updated attributes
  """
  @spec update(
    id: binary,
    status: binary,
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IssuingToken.t()} |
    {:error, [Error.t()]}
  def update(id, parameters \\ []) do
    Rest.patch_id(
      resource(),
      id,
      parameters
    )
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(
    id: binary,
    status: binary,
    tags: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def update!(id, parameters \\ []) do
    Rest.patch_id!(
      resource(),
      id,
      parameters
    )
  end

  @doc """
  Cancel an IssuingToken entity previously created in the Stark Infra API. This action is irreversible.

  ## Parameters (required):
    - `:id` [string]: IssuingToken unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled IssuingToken struct
  """
  @spec cancel(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IssuingToken.t()} |
    {:error, [Error.t()]}
  def cancel(id, options \\ []) do
    Rest.delete_id(
      resource(),
      id,
      options
    )
  end

  @doc """
  Same as cancel(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec cancel!(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def cancel!(id, options \\ []) do
    Rest.delete_id!(
      resource(),
      id,
      options
    )
  end

  @doc """
  Create a single IssuingToken struct from a content string received from a handler listening at the
  registered tokenAuthorizationUrl or tokenActivationUrl endpoint.
  If the provided digital signature does not check out with the StarkInfra public key, a
  starkinfra.error.InvalidSignatureError will be raised.

  ## Parameters (required):
    - `:content` [string]: response content from request received at user endpoint (not parsed)
    - `:signature` [string]: base-64 digital signature received at response header "Digital-Signature"

  ## Options:
    - `:cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Parsed IssuingToken struct
  """
  @spec parse(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  ) ::
    {:ok, {IssuingToken.t(), binary}} |
    {:error, [Error.t()]}
  def parse(options) do
    %{content: content, signature: signature, cache_pid: cache_pid, user: user} =
      Enum.into(
        options |> Check.enforced_keys([:content, :signature]),
        %{cache_pid: nil, user: nil}
      )
    Parse.parse_and_verify(
      content: content,
      signature: signature,
      cache_pid: cache_pid,
      key: nil,
      resource_maker: &resource_maker/1,
      user: user
    )
  end

  @doc """
  Same as parse(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  ) :: any
  def parse!(options \\ []) do
    %{content: content, signature: signature, cache_pid: cache_pid, user: user} =
      Enum.into(
        options |> Check.enforced_keys([:content, :signature]),
        %{cache_pid: nil, user: nil}
      )
    Parse.parse_and_verify!(
      content: content,
      signature: signature,
      cache_pid: cache_pid,
      key: nil,
      resource_maker: &resource_maker/1,
      user: user
    )
  end

  @doc """
  Helps you respond to IssuingToken authorization requests.

  When a new tokenization is triggered by your user, a POST request will be made to your registered
  tokenAuthorizationUrl to get your decision to complete the tokenization. The POST request must be
  answered in the following format, within 2 seconds, and with an HTTP status code 200.

  ## Parameters (required):
    - `:status` [string]: sub-issuer response to the authorization. Options: "approved", "denied"

  ## Options:
    - `:reason` [string, default ""]: denial reason. Options: "other", "bruteForce", "subIssuerError", "lostCard", "invalidCard", "invalidHolder", "expiredCard", "canceledCard", "blockedCard", "invalidExpiration", "invalidSecurityCode", "missingTokenAuthorizationUrl", "maxCardTriesExceeded", "maxWalletInstanceTriesExceeded"
    - `:activation_methods` [list of maps, default nil]: list of maps with "type" and "value" string pairs. ex: [%{"type" => "app", "value" => "com.subissuer.android"}]
    - `:design_id` [string, default nil]: design unique id. ex: "5656565656565656"
    - `:tags` [list of strings, default nil]: tags to filter retrieved struct. ex: ["tony", "stark"]

  ## Return:
    - Dumped JSON string that must be returned to us on the IssuingToken authorization request
  """
  @spec response_authorization!(
    status: binary,
    reason: binary,
    activation_methods: [map()],
    design_id: binary,
    tags: [binary]
  ) :: any
  def response_authorization!(status, options \\ []) do
    params =
      options
      |> Enum.into(%{reason: "", activation_methods: nil, design_id: nil, tags: nil})
      |> Map.put(:status, status)

    %{authorization: params}
    |> API.cast_json_to_api_format()
    |> JSON.encode!()
  end

  @doc """
  Helps you respond to IssuingToken activation requests.

  When a new token activation is triggered by your user, a POST request will be made to your registered
  tokenActivationUrl for you to confirm the activation code you informed to them. You may identify this
  request through the present activation_code in the payload. The POST request must be answered in the
  following format, within 2 seconds, and with an HTTP status code 200.

  ## Parameters (required):
    - `:status` [string]: sub-issuer response to the activation. Options: "approved", "denied"

  ## Options:
    - `:reason` [string, default ""]: denial reason. Options: "other", "bruteForce", "subIssuerError", "lostCard", "invalidCard", "invalidHolder", "expiredCard", "canceledCard", "blockedCard", "invalidExpiration", "invalidSecurityCode", "missingTokenAuthorizationUrl", "maxCardTriesExceeded", "maxWalletInstanceTriesExceeded"
    - `:tags` [list of strings, default nil]: tags to filter retrieved struct. ex: ["tony", "stark"]

  ## Return:
    - Dumped JSON string that must be returned to us on the IssuingToken activation request
  """
  @spec response_activation!(
    status: binary,
    reason: binary,
    tags: [binary]
  ) :: any
  def response_activation!(status, options \\ []) do
    params =
      options
      |> Enum.into(%{reason: "", tags: nil})
      |> Map.put(:status, status)

    %{authorization: params}
    |> API.cast_json_to_api_format()
    |> JSON.encode!()
  end

  @doc false
  def resource() do
    {
      "IssuingToken",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingToken{
      id: json[:id],
      card_id: json[:card_id],
      wallet_id: json[:wallet_id],
      wallet_name: json[:wallet_name],
      merchant_id: json[:merchant_id],
      external_id: json[:external_id],
      wallet_device_score: json[:wallet_device_score],
      wallet_account_score: json[:wallet_account_score],
      status: json[:status],
      tags: json[:tags],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
