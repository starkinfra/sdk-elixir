defmodule StarkInfraTest.Utils.IssuingHolder do
  use ExUnit.Case

  def random_string(length) do
    for _ <- 1..length, into: "", do: <<Enum.random('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYZ')>>
  end

  def example_issuing_holder do
    %StarkInfra.IssuingHolder{
      name: "Iron Bank S.A.",
      external_id: random_string(15),
      tax_id: "012.345.678-90",
      tags: ["Traveler Employee"]
    }
  end
end
