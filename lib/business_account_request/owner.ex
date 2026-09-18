defmodule StarkInfra.BusinessAccountRequest.Owner do
  alias __MODULE__, as: Owner

  @moduledoc """
  Groups BusinessAccountRequest.Owner related functions
  """

  @doc """
  The Owner object represents a company owner referenced by a BusinessAccountRequest.
  Each owner completes its own identity verification through an independent webview.
  It is embedded on the parent's `:owners` field and has no endpoints of its own.

  ## Parameters (required):
    - `:tax_id` [string]: owner's tax ID (CPF). ex: "012.345.678-90"
    - `:name` [string]: owner's full name (minimum 5 characters). ex: "Jamie Lannister"
    - `:role` [string]: owner's role in the company. Options: "partner", "representative"

  ## Attributes (return-only):
    - `:identity_id` [string]: unique id of the identity verification linked to this owner. ex: "5709594221805568"
    - `:validator_link` [string]: webview link to be delivered to the owner to complete biometrics and document capture.
    - `:status` [string]: current status of the owner verification. Options: "created", "approved", "denied"
  """
  @enforce_keys [
    :tax_id,
    :name,
    :role
  ]
  defstruct [
    :tax_id,
    :name,
    :role,
    :identity_id,
    :validator_link,
    :status
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def resource_maker(json) do
    %Owner{
      tax_id: json[:tax_id],
      name: json[:name],
      role: json[:role],
      identity_id: json[:identity_id],
      validator_link: json[:validator_link],
      status: json[:status]
    }
  end
end
