defmodule StarkInfraTest.Ledger.Log do
  use ExUnit.Case

  @tag :ledger_log
  test "get ledger log" do
    log =
      StarkInfra.Ledger.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, unique_log} = StarkInfra.Ledger.Log.get(log.id)
    assert unique_log.id == log.id
  end

  @tag :ledger_log
  test "get! ledger log" do
    log =
      StarkInfra.Ledger.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    unique_log = StarkInfra.Ledger.Log.get!(log.id)
    assert unique_log.id == log.id
  end

  @tag :ledger_log
  test "query ledger log" do
    StarkInfra.Ledger.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :ledger_log
  test "query! ledger log" do
    StarkInfra.Ledger.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :ledger_log
  test "page ledger log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.Ledger.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :ledger_log
  test "page! ledger log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.Ledger.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
