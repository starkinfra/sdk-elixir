defmodule StarkInfra.CreditSigner do
  alias __MODULE__, as: CreditSigner
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups CreditSigner related functions
  """

  @doc """
  CreditNote signer's information.

  ## Parameters (required):
    - `:name` [string]: signer's name. ex: "Tony Stark"
    - `:contact` [string]: signer's contact that receives the signing link or token. Can be an email, a phone number or, for the "server" and "organization" methods, a URL. ex: "tony@starkindustries.com"
    - `:method` [string]: delivery method for the contract. Options: "link" (signing link sent to the contact), "token" (signing token sent to the contact), "server" and "organization" (automatic signatures over URL contacts)

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the CreditSigner is created. ex: "5656565656565656"
    - `:signed` [DateTime]: datetime when the signer signed the contract. nil until the signature happens. ex: ~U[2022-06-02 00:00:00.000000Z]
  """
  @enforce_keys [
    :name,
    :contact,
    :method
  ]
  defstruct [
    :name,
    :contact,
    :method,
    :id,
    :signed
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Resend the signing token to a specific CreditSigner.

  ## Parameters (required):
    - `:id` [string]: CreditSigner unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CreditSigner struct with updated attributes
  """
  @spec resend_token(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, CreditSigner.t()} |
    {:error, [Error.t()]}
  def resend_token(id, options \\ []) do
    Rest.patch_id(resource(), id, Keyword.merge(options, is_sent: false))
  end

  @doc """
  Same as resend_token(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec resend_token!(
    binary,
    user: Project.t() | Organization.t() | nil
  ) :: CreditSigner.t()
  def resend_token!(id, options \\ []) do
    Rest.patch_id!(resource(), id, Keyword.merge(options, is_sent: false))
  end

  @doc false
  def resource() do
    {
      "CreditSigner",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %CreditSigner{
      name: json[:name],
      contact: json[:contact],
      method: json[:method],
      id: json[:id],
      signed: json[:signed] |> Check.datetime()
    }
  end
end
