defmodule StarkInfraTest.Utils.LedgerTransaction do
  def example_ledger_transaction(ledger_id) do
    %StarkInfra.LedgerTransaction{
      amount: 100,
      ledger_id: ledger_id,
      external_id: "ledger-transaction-" <> StarkInfraTest.Utils.Random.random_string(10),
      source: "bank-transfer/123"
    }
  end
end
