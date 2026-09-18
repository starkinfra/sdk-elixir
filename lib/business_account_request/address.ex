defmodule StarkInfra.BusinessAccountRequest.Address do
  alias __MODULE__, as: Address

  @moduledoc """
  Groups BusinessAccountRequest.Address related functions
  """

  @doc """
  The Address object is the structured address of the company referenced by a
  BusinessAccountRequest. It is embedded on the parent's `:address` field and
  has no endpoints of its own.

  ## Parameters (required):
    - `:street` [string]: street name. ex: "Av. Faria Lima"
    - `:number` [string]: street number. ex: "2000"
    - `:neighborhood` [string]: neighborhood / district. ex: "Itaim Bibi"
    - `:city` [string]: city. ex: "Sao Paulo"
    - `:state` [string]: state (BR 2-letter code). ex: "SP"
    - `:zip_code` [string]: ZIP code (BR CEP), formatted or digit-only. ex: "04538-132"

  ## Parameters (optional):
    - `:complement` [string, default nil]: address complement. ex: "Sala 42"
  """
  @enforce_keys [
    :street,
    :number,
    :neighborhood,
    :city,
    :state,
    :zip_code
  ]
  defstruct [
    :street,
    :number,
    :neighborhood,
    :city,
    :state,
    :zip_code,
    :complement
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def resource_maker(json) do
    %Address{
      street: json[:street],
      number: json[:number],
      neighborhood: json[:neighborhood],
      city: json[:city],
      state: json[:state],
      zip_code: json[:zip_code],
      complement: json[:complement]
    }
  end
end
