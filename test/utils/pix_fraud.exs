defmodule StarkInfraTest.Utils.PixFraud do
  use ExUnit.Case

  def random_string(length) do
    for _ <- 1..length, into: "", do: <<Enum.random(~c"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYZ")>>
  end

  def generate_example_pix_fraud do
    %StarkInfra.PixFraud{
      external_id: random_string(32),
      type: "mule",
      tax_id: "012.345.678-90",
      tags: ["fraudulent"]
    }
  end
end
