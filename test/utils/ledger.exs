defmodule StarkInfraTest.Utils.Ledger do
  def example_ledger() do
    %StarkInfra.Ledger{
      external_id: "ledger-" <> StarkInfraTest.Utils.Random.random_string(10)
    }
  end
end
