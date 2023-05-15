defmodule StarkInfra.MerchantCategory do
  alias __MODULE__, as: MerchantCategory
  alias StarkInfra.Error
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization

  @moduledoc """
  Groups MerchantCategory related functions
  """

  @doc """
  MerchantCategory's codes and types are used to define categories filters in IssuingRules.
  A MerchantCategory filter must define exactly one parameter between code and type.
  A type, such as "food", "services", etc., defines an entire group of merchant codes,
  whereas a code only specifies a specific MCC.

  ## Parameters (conditionally required):
    - `:code` [binary, default nil]: category's code. ex: "veterinaryServices", "fastFoodRestaurants"
    - `:type` [binary, default nil]: category's type. ex: "pets", "food"

    ## Attributes (return-only):
    - `:name` [binary]: category's name. ex: "Veterinary services", "Fast food restaurants"
    - `:number` [binary]: category's number. ex: "742", "5814"
  """
  @enforce_keys [
    :code,
    :type
  ]
  defstruct [
    :code,
    :type,
    :name,
    :number
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of MerchantCategory objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:search` [binary, default nil]: keyword to search for code, type, name or number
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of MerchantCategory objects with updated attributes
  """
  @spec query(
    search: binary,
    user: (Organization.t() | Project.t()) | nil
  ) ::
    {:ok, [MerchantCategory.t()]} |
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
