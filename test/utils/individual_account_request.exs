defmodule StarkInfraTest.Utils.IndividualAccountRequest do
  use ExUnit.Case

  alias StarkInfra.IndividualAccountRequest
  alias StarkInfra.IndividualAccountRequest.Address

  def generate_example_address do
    %Address{
      street: "Rua do Estilo Barroco",
      number: "648",
      neighborhood: "Santo Amaro",
      city: "Sao Paulo",
      state: "SP",
      zip_code: "05724005",
      complement: "Apto. 123"
    }
  end

  def generate_example_individual_account_request do
    %IndividualAccountRequest{
      name: "Jamie Lannister",
      tax_id: "012.345.678-90",
      address: generate_example_address(),
      income: 1_000_000,
      birth_date: "2012-03-06",
      tags: ["test", "testing"]
    }
  end

  @doc """
  IndividualAccountRequest and IndividualAccountAttachment are validated by a
  second sandbox project shared by no other lane. The default project (set in
  config) is probed first; only when it answers a permission-class error do
  tests fall back to the dedicated account-request project from the env.
  """
  def user_opts do
    case IndividualAccountRequest.query(limit: 1) |> Enum.take(1) do
      [{:error, errors}] ->
        if Enum.any?(errors, &(&1.code in ["invalidPermission", "invalidProject", "invalidProfile"])) do
          [user: account_request_project()]
        else
          []
        end
      _ ->
        []
    end
  end

  defp account_request_project do
    StarkInfra.project(
      environment: :sandbox,
      id: System.get_env("SANDBOX_INFRA_ACCOUNT_REQUEST_ID"),
      private_key: System.get_env("SANDBOX_INFRA_ACCOUNT_REQUEST_PRIVATE_KEY")
    )
  end
end
