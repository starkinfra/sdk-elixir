defmodule StarkInfraTest.Utils.IssuingInvoice do
  use ExUnit.Case

  def example_issuing_invoice() do
    %StarkInfra.IssuingInvoice{
      amount: Enum.random(1000..10000)
    }
  end
end
