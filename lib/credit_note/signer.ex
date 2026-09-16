defmodule StarkInfra.CreditNote.Signer do
  alias __MODULE__, as: Signer
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups Signer related functions
  """

  @doc """
  CreditNote signer's information.

  ## Parameters (required):
    - `:name` [string]: signer's name. ex: "Tony Stark"
    - `:contact` [string]: signer's contact information. ex: "tony@starkindustries.com"
    - `:method` [string]: delivery method for the contract. Options: "link" (signing link sent to the contact), "token" (signing token sent to the contact), "server" and "organization" (automatic signatures, no contact delivery). ex: "link"

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when the Signer is created. ex: "5656565656565656"
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
    :id
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Resend the signing token to a specific CreditNote signer.

  ## Parameters (required):
    - `:id` [string]: Signer's unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Signer struct with updated attributes
  """
  @spec resend_token(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, Signer.t()} |
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
  ) :: Signer.t()
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
    %Signer{
      name: json[:name],
      contact: json[:contact],
      method: json[:method],
      id: json[:id]
    }
  end
end
