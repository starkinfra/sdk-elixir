defmodule StarkInfraTest.Utils.IndividualIdentity do
  use ExUnit.Case

  alias StarkInfra.IndividualIdentity

  def generate_example_individual_identity do
    %IndividualIdentity{
      name: "Walter White",
      email: "walter.white@email.com",
      delivery_method: "automatic",
      proofs: ["identity"],
      tax_id: "012.345.678-90",
      tags: ["test", "testing"]
    }
  end
end
