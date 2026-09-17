defmodule StarkInfraTest.Utils.DynamicBrcode do
  use ExUnit.Case

  def generate_example_dynamic_brcode() do
    %StarkInfra.DynamicBrcode{
      name: "Jamie Lannister",
      city: "Rio de Janeiro",
      external_id: StarkInfraTest.Utils.Random.random_string(32),
      type: "instant",
      tags: ["test"]
    }
  end
end
