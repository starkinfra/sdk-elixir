defmodule StarkInfraTest.Utils.BusinessIdentity do
  def generate_example_business_identity do
    %StarkInfra.BusinessIdentity{
      tax_id: "20.018.183/0001-80",
      tags: ["onboarding-123"]
    }
  end
end
