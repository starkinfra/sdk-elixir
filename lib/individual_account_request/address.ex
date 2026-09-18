defmodule StarkInfra.IndividualAccountRequest.Address do
  alias __MODULE__, as: Address

  @moduledoc """
  Groups IndividualAccountRequest.Address related functions
  """

  @doc """
  The Address object is the structured residential address of the individual referenced by
  an IndividualAccountRequest. It is embedded in the parent's `:address` field and has no
  endpoints of its own.

  ## Parameters (required):
    - `:street` [string]: street name. ex: "Rua do Estilo Barroco"
    - `:number` [string]: street number. ex: "648"
    - `:neighborhood` [string]: neighborhood / district. ex: "Santo Amaro"
    - `:city` [string]: city. ex: "Sao Paulo"
    - `:state` [string]: state (BR 2-letter code). ex: "SP"
    - `:zip_code` [string]: ZIP code (BR CEP), formatted or digit-only. ex: "05724005"

  ## Parameters (optional):
    - `:complement` [string, default nil]: address complement. ex: "Apto. 123"
  """
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
