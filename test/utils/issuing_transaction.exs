defmodule StarkInfraTest.Utils.IssuingTransaction do
  use ExUnit.Case

  def example_issuing_transaction() do
    %StarkInfra.IssuingTransaction{
      amount: 10,
      external_id: "123456789012345",
      description: "Issuing Transaction test"
    }
  end

end
