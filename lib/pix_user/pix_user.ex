defmodule StarkInfra.PixUser do
  alias __MODULE__, as: PixUser
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.API
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error
  alias StarkInfra.PixUser.Statistics

  @moduledoc """
  Groups PixUser related functions
  """

  @doc """
  Pix Users are used to get fraud statistics of a user.

  ## Parameters (required):
    - `:id` [string]: user tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"

  ## Attributes (return-only):
    - `:statistics` [list of PixUser.Statistics structs, default nil]: list of PixUser.Statistics structs. ex: [%StarkInfra.PixUser.Statistics{after: ~U[2023-11-06 18:57:08.325090Z], source: "pix-key"}]
  """
  @enforce_keys [
    :id
  ]
  defstruct [
    :id,
    :statistics
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single PixUser struct information by passing its tax ID

  ## Parameters (required):
    - `:id` [string]: user tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"

  ## Options:
    - `:key_id` [string, default nil]: marked PixKey id. ex: "+5511989898989"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixUser struct that corresponds to the given id.
  """
  @spec get(
    binary,
    key_id: binary | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixUser.t()} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(
    binary,
    key_id: binary | nil,
    user: Project.t() | Organization.t() | nil
  ) :: PixUser.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc false
  def resource() do
    {
      "PixUser",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %PixUser{
      id: json[:id],
      statistics: json[:statistics] && Enum.map(json[:statistics], fn statistic -> API.from_api_json(statistic, &Statistics.resource_maker/1) end)
    }
  end
end
