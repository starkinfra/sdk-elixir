defmodule StarkInfraTest.Utils.BusinessAccountRequest do
  def generate_example_business_account_request do
    %StarkInfra.BusinessAccountRequest{
      address: %StarkInfra.BusinessAccountRequest.Address{
        street: "Av. Faria Lima",
        number: "2000",
        neighborhood: "Itaim Bibi",
        city: "Sao Paulo",
        state: "SP",
        zip_code: "04538-132",
        complement: "Sala 42"
      },
      revenue: 100_000_000,
      name: "Stark Bank S.A.",
      tax_id: "20.018.183/0001-80",
      owners: [
        %StarkInfra.BusinessAccountRequest.Owner{
          tax_id: "012.345.678-90",
          name: "Jamie Lannister",
          role: "partner"
        }
      ],
      tags: ["test", "testing"]
    }
  end

  def project do
    StarkInfra.project(
      environment: :sandbox,
      id: System.get_env("SANDBOX_INFRA_ACCOUNT_REQUEST_ID"),
      private_key: System.get_env("SANDBOX_INFRA_ACCOUNT_REQUEST_PRIVATE_KEY")
    )
  end
end
