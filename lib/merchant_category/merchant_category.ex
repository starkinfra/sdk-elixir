defmodule StarkInfra.MerchantCategory do
  alias __MODULE__, as: MerchantCategory
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups MerchantCategory related functions
  """

  @doc """
  MerchantCategory's codes and types are used to define category filters in IssuingRules.
  A category is identified either by its code, which specifies a single MCC, or by its type,
  which defines an entire group of merchant codes, such as "food" or "services".

  ## Attributes (return-only):
    - `:code` [string]: category's code, which specifies a single MCC. ex: "fastFoodRestaurants"
    - `:type` [string]: category's type, which defines an entire group of merchant codes. Options: "unknown", "pets", "food", "fuel", "retail", "health", "hotels", "leisure", "services", "clothing", "gambling", "airlines", "carRental", "education", "groceries", "financial", "government", "organizations", "transportation".
    - `:name` [string]: category's name. ex: "Fast food restaurants"
    - `:number` [string]: category's number. ex: "5814"
  """
  defstruct [
    :code,
    :type,
    :name,
    :number
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of MerchantCategory structs available in the Stark Infra API

  ## Options:
    - `:search` [string, default nil]: keyword to search for code, type, name or number. ex: "food"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of MerchantCategory structs with updated attributes
  """
  @spec query(
    search: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [MerchantCategory.t()]} |
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
      "MerchantCategory",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %MerchantCategory{
      code: json[:code],
      type: json[:type],
      name: json[:name],
      number: json[:number]
    }
  end
end
