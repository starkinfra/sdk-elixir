defmodule StarkInfra.MerchantCountry do
  alias __MODULE__, as: MerchantCountry
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups MerchantCountry related functions
  """

  @doc """
  MerchantCountry's codes are used to define country filters in IssuingRules.

  ## Attributes (return-only):
    - `:code` [string]: country's code. ex: "BRA"
    - `:name` [string]: country's name. ex: "Brazil"
    - `:number` [string]: country's number. ex: "076"
    - `:short_code` [string]: country's short code. ex: "BR"
  """
  @enforce_keys [
    :code
  ]
  defstruct [
    :code,
    :name,
    :number,
    :short_code
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of MerchantCountry structs available in the Stark Infra API

  ## Options:
    - `:search` [string, default nil]: keyword to search for code, name, number or short_code. ex: "brazil"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of MerchantCountry structs with updated attributes
  """
  @spec query(
    search: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [MerchantCountry.t()]} |
    {:error, Error.t()}
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
    search: binary,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc false
  def resource() do
    {
      "MerchantCountry",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %MerchantCountry{
      code: json[:code],
      name: json[:name],
      number: json[:number],
      short_code: json[:short_code]
    }
  end
end
