defmodule StarkInfra.CreditSigner do
  alias __MODULE__, as: CreditSigner

  @moduledoc """
  Groups CreditSigner related functions
  """

  @doc """
  CreditNote signer's information.

  ## Parameters (required):
    - `:name` [binary]: signer's name. ex: "Tony Stark"
    - `:contact` [binary]: signer's contact information. ex: "tony@starkindustries.com"
    - `:method` [binary]: delivery method for the contract. ex: "link"

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the CreditSigner is created. ex: "5656565656565656"
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
      id: json[:id]
    }
  end
end
