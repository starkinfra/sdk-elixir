defmodule StarkInfra.CardMethod do
  alias __MODULE__, as: CardMethod
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups CardMethod related functions
  """

  @doc """
  CardMethod's codes are used to define methods filters in IssuingRules.

  ## Attributes (return-only):
    - `:code` [string]: method's code. Options: "chip", "token", "server", "manual", "magstripe", "contactless".
    - `:name` [string]: method's name. ex: "token"
    - `:number` [string]: method's number. ex: "81"
  """
  @enforce_keys [
    :code
  ]
  defstruct [
    :code,
    :name,
    :number
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of CardMethod structs available in the Stark Infra API

  ## Options:
    - `:search` [string, default nil]: keyword to search for code, name or number. ex: "token"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CardMethod structs with updated attributes
  """
  @spec query(
    search: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [CardMethod.t()]} |
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
      "CardMethod",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %CardMethod{
      code: json[:code],
      name: json[:name],
      number: json[:number]
    }
  end
end
