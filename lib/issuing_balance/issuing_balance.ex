defmodule StarkInfra.IssuingBalance do
  alias __MODULE__, as: IssuingBalance
  alias StarkInfra.Error
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization

  @moduledoc """
  Groups IssuingBalance related functions
  """

  @doc """
  The IssuingBalance object displays the current issuing balance of the Workspace,
  which is the result of the sum of all transactions within this
  Workspace. The balance is never generated by the user, but it
  can be retrieved to see the available information.

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when IssuingBalance is created. ex: "5656565656565656"
    - `:amount` [integer]: current balance amount of the Workspace in cents. ex: 200 (= R$ 2.00)
    - `:currency` [binary]: currency of the current Workspace. Expect others to be added eventually. ex: "BRL"
    - `:updated` [DateTime]: latest update DateTime for the IssuingBalance. ex: ~U[2020-3-10 10:30:0:0]
  """
  @enforce_keys [
    :id,
    :amount,
    :currency,
    :updated
  ]
  defstruct [
    :id,
    :amount,
    :currency,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive the IssuingBalance object linked to your Workspace in the Stark Infra API

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - IssuingBalance object that corresponds to the given id.
  """
  @spec get(
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [IssuingBalance.t()] } |
    { :error, [error: Error.t()] }
  def get(options \\ []) do
    case Rest.get_list(resource(), options) |> Enum.take(1) do
      [{:ok, balance}] -> {:ok, balance}
      [{:error, error}] -> {:error, error}
    end
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(
    user: Project.t() | Organization.t() | nil
  ) :: any
  def get!(options \\ []) do
    Rest.get_list!(resource(), options) |> Enum.take(1) |> hd()
  end

  @doc false
  def resource() do
    {
      "IssuingBalance",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssuingBalance{
      id: json[:id],
      amount: json[:amount],
      currency: json[:currency],
      updated: json[:updated] |> Check.datetime()
    }
  end
end
