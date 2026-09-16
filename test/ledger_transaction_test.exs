defmodule StarkInfraTest.LedgerTransaction do
  use ExUnit.Case

  @tag :ledger_transaction
  test "create ledger transaction" do
    ledger = StarkInfra.Ledger.create!([StarkInfraTest.Utils.Ledger.example_ledger()]) |> hd

    {:ok, transactions} = StarkInfra.LedgerTransaction.create([
      StarkInfraTest.Utils.LedgerTransaction.example_ledger_transaction(ledger.id)
    ])
    transaction = transactions |> hd
    assert !is_nil(transaction.id)
  end

  @tag :ledger_transaction
  test "create! ledger transaction" do
    ledger = StarkInfra.Ledger.create!([StarkInfraTest.Utils.Ledger.example_ledger()]) |> hd

    transaction = StarkInfra.LedgerTransaction.create!([
      StarkInfraTest.Utils.LedgerTransaction.example_ledger_transaction(ledger.id)
    ]) |> hd
    assert !is_nil(transaction.id)
  end

  @tag :ledger_transaction
  test "get ledger transaction" do
    ledger = StarkInfra.Ledger.create!([StarkInfraTest.Utils.Ledger.example_ledger()]) |> hd
    StarkInfra.LedgerTransaction.create!([
      StarkInfraTest.Utils.LedgerTransaction.example_ledger_transaction(ledger.id)
    ])

    StarkInfra.LedgerTransaction.query!(ledger_id: ledger.id, limit: 5)
      |> Enum.map(fn(transaction) ->
        {:ok, retrieved_transaction} = StarkInfra.LedgerTransaction.get(transaction.id)
        assert transaction.id == retrieved_transaction.id
      end)
  end

  @tag :ledger_transaction
  test "get! ledger transaction" do
    ledger = StarkInfra.Ledger.create!([StarkInfraTest.Utils.Ledger.example_ledger()]) |> hd
    StarkInfra.LedgerTransaction.create!([
      StarkInfraTest.Utils.LedgerTransaction.example_ledger_transaction(ledger.id)
    ])

    StarkInfra.LedgerTransaction.query!(ledger_id: ledger.id, limit: 8)
      |> Enum.map(fn(transaction) ->
        assert transaction.id == StarkInfra.LedgerTransaction.get!(transaction.id).id
      end)
  end

  @tag :ledger_transaction
  test "query ledger transaction" do
    ledger = StarkInfra.Ledger.create!([StarkInfraTest.Utils.Ledger.example_ledger()]) |> hd
    StarkInfra.LedgerTransaction.create!([
      StarkInfraTest.Utils.LedgerTransaction.example_ledger_transaction(ledger.id)
    ])

    transactions = StarkInfra.LedgerTransaction.query(ledger_id: ledger.id, limit: 5)
      |> Enum.take(200)
    assert length(transactions) <= 5
  end

  @tag :ledger_transaction
  test "query! ledger transaction" do
    ledger = StarkInfra.Ledger.create!([StarkInfraTest.Utils.Ledger.example_ledger()]) |> hd
    StarkInfra.LedgerTransaction.create!([
      StarkInfraTest.Utils.LedgerTransaction.example_ledger_transaction(ledger.id)
    ])

    transactions = StarkInfra.LedgerTransaction.query!(ledger_id: ledger.id, limit: 5)
      |> Enum.map(fn(transaction) ->
        assert transaction.id == StarkInfra.LedgerTransaction.get!(transaction.id).id
      end)
    assert length(transactions) <= 5
  end

  @tag :ledger_transaction
  test "page ledger transaction" do
    ledger = StarkInfra.Ledger.create!([StarkInfraTest.Utils.Ledger.example_ledger()]) |> hd
    StarkInfra.LedgerTransaction.create!([
      StarkInfraTest.Utils.LedgerTransaction.example_ledger_transaction(ledger.id),
      StarkInfraTest.Utils.LedgerTransaction.example_ledger_transaction(ledger.id),
      StarkInfraTest.Utils.LedgerTransaction.example_ledger_transaction(ledger.id)
    ])

    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.LedgerTransaction.page/1, 2, ledger_id: ledger.id, limit: 2)
    assert length(ids) <= 10

    Enum.map(ids, fn(id) ->
      assert id == StarkInfra.LedgerTransaction.get!(id).id
    end)
  end

  @tag :ledger_transaction
  test "page! ledger transaction" do
    ledger = StarkInfra.Ledger.create!([StarkInfraTest.Utils.Ledger.example_ledger()]) |> hd
    StarkInfra.LedgerTransaction.create!([
      StarkInfraTest.Utils.LedgerTransaction.example_ledger_transaction(ledger.id),
      StarkInfraTest.Utils.LedgerTransaction.example_ledger_transaction(ledger.id),
      StarkInfraTest.Utils.LedgerTransaction.example_ledger_transaction(ledger.id)
    ])

    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.LedgerTransaction.page!/1, 2, ledger_id: ledger.id, limit: 2)
    assert length(ids) <= 10

    Enum.map(ids, fn(id) ->
      assert id == StarkInfra.LedgerTransaction.get!(id).id
    end)
  end
end
