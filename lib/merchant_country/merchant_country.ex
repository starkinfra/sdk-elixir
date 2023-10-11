defmodule StarkInfra.MerchantCountry do
  alias __MODULE__, as: MerchantCountry
  alias StarkInfra.Error
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization

  @moduledoc """
  Groups MerchantCountry related functions
  """

  @doc """
  MerchantCountry's codes are used to define country filters in IssuingRules.

  ## Parameters (required):
    - `:code` [binary]: country's code. ex: "BRA"

    ## Attributes (return-only):
    - `:name` [binary]: country's name. ex: "Brazil"
    - `:number` [binary]: country's number. ex: "076"
    - `:short_code` [binary]: country's short code. ex: "BR"
  """
  @enforce_keys [
    :code
  ]
  defstruct [
    :code,
    :name,
    :number,
    :short_code,
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of MerchantCountry objects available in the Stark Infra API

  ## Parameters (optional):
    - `:search` [binary, default nil]: keyword to search for code, name, number or short_code
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of MerchantCountry objects with updated attributes
  """
  @spec query(
    search: binary,
    user: (Organization.t() | Project.t()) | nil
  ) ::
    {:ok, [MerchantCountry.t()]} |
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
    search: binary,
    user: (Organization.t() | Project.t()) | nil
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
      short_code: json[:short_code],
    }
  end
end
