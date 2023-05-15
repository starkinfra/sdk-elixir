defmodule StarkInfra.CardMethod do
  alias __MODULE__, as: CardMethod
  alias StarkInfra.Error
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Organization

  @moduledoc """
  Groups CardMethod related functions
  """

  @doc """
  CardMethod's codes are used to define methods filters in IssuingRules.

  ## Parameters (required):
    - `:code` [binary]: method's code. ex: "chip", "token", "server", "manual", "magstripe", "contactless"

  ## Attributes (return-only):
    - `:name` [binary]: method's name. ex: "token"
    - `:number` [binary]: method's number. ex: "81"
  """
  @enforce_keys [
    :code,
  ]
  defstruct [
    :code,
    :name,
    :number
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of CardMethod objects available in the Stark Infra API

  ## Parameters (optional):
    - `:search` [binary, default nil]: keyword to search for code, name or number. ex: "token"
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CardMethod objects with updated attributes
  """
  @spec query(
    search: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, {:ok, [CardMethod.t()]}} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query(options \\ []) do
    Rest.get_list(resource(), options)
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
    search: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    ({:cont, [CardMethod.t()]} |
    {:error, [Error.t()]} |
    {:halt, any} |
    {:suspend, any},
    any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
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
