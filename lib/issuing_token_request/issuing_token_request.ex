defmodule StarkInfra.IssuingTokenRequest do
  alias __MODULE__, as: IssuingTokenRequest
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IssuingTokenRequest related functions
  """

  @doc """
  The IssuingTokenRequest struct displays the necessary information to proceed with the card tokenization.
  When you initialize an IssuingTokenRequest, the entity will not be automatically created in the Stark
  Infra API. The 'create' function sends the struct to the Stark Infra API and returns the payload needed
  to proceed with the tokenization on the wallet app.

  ## Parameters (required):
    - `:card_id` [string]: id of the IssuingCard to be tokenized. ex: "5734340247945216"
    - `:wallet_id` [string]: id of the digital wallet requesting tokenization. Options: "apple", "google", "merchant"
    - `:method_code` [string]: provisioning method. Options: "app", "manual"

  ## Parameters (optional):
    - `:metadata` [map, default nil]: additional information you want to send along with the tokenization request. ex: %{"authorizationId" => "OjZAqj"}

  ## Attributes (return-only):
    - `:content` [string]: token request content. ex: "eyJwdWJsaWNLZXlGaW5nZXJwcmludCI6ICJlNTNiZThjZTRhYWQxNWU2OWNmMjExOTA5Mjk4YzJkOTE0O..."
    - `:signature` [string]: token request signature. ex: "eyJwdWJsaWNLZXlGaW5nZXJwcmludCI6ICJlNTNiZThjZTRhYWQxNWU2OWNmMjExOTA5Mjk4YzJkOTE0O..."
  """
  @enforce_keys [
    :card_id,
    :wallet_id,
    :method_code
  ]
  defstruct [
    :card_id,
    :wallet_id,
    :method_code,
    :content,
    :signature,
    :metadata
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send an IssuingTokenRequest struct to the Stark Infra API to generate the payload needed to proceed
  with the card tokenization.

  ## Parameters (required):
    - `:request` [IssuingTokenRequest struct]: IssuingTokenRequest struct to be sent to the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingTokenRequest struct with updated attributes
  """
  @spec create(
    request: IssuingTokenRequest.t() | map(),
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, IssuingTokenRequest.t()} |
    {:error, [Error.t()]}
  def create(request, options \\ []) do
    Rest.post_single(
      resource(),
      request,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    request: IssuingTokenRequest.t() | map(),
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(request, options \\ []) do
    Rest.post_single!(
      resource(),
      request,
      options
    )
  end

  @doc false
  def resource() do
    {
      "IssuingTokenRequest",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingTokenRequest{
      card_id: json[:card_id],
      wallet_id: json[:wallet_id],
      method_code: json[:method_code],
      content: json[:content],
      signature: json[:signature],
      metadata: json[:metadata]
    }
  end
end
