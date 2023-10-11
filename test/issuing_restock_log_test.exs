defmodule StarkInfraTest.IssuingRestock.Log do
  use ExUnit.Case

  @tag :issuing_restock_log
  test "get issuing restock log" do
    log =
      StarkInfra.IssuingRestock.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkInfra.IssuingRestock.Log.get(log.id)
  end

  @tag :issuing_restock_log
  test "get! issuing restock log" do
    log =
      StarkInfra.IssuingRestock.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    _log = StarkInfra.IssuingRestock.Log.get!(log.id)
  end

  @tag :issuing_restock_log
  test "query issuing restock log" do
    StarkInfra.IssuingRestock.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :issuing_restock_log
  test "query! issuing restock log" do
    StarkInfra.IssuingRestock.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :issuing_restock_log
  test "query! issuing restock log with filters" do
    restocks = StarkInfra.IssuingRestock.query!(limit: 10)
    |> Enum.take(1)
    |> hd()

    StarkInfra.IssuingRestock.Log.query!(limit: 1, restock_ids: [restocks.id], types: ["created"])
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :issuing_restock_log
  test "page issuing restock log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingRestock.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_restock_log
  test "page! issuing restock log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingRestock.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
