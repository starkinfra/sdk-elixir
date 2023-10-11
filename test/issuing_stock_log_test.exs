defmodule StarkInfraTest.IssuingStock.Log do
  use ExUnit.Case

  @tag :issuing_stock_log
  test "get issuing stock log" do
    log =
      StarkInfra.IssuingStock.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkInfra.IssuingStock.Log.get(log.id)
  end

  @tag :issuing_stock_log
  test "get! issuing stock log" do
    log =
      StarkInfra.IssuingStock.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    _log = StarkInfra.IssuingStock.Log.get!(log.id)
  end

  @tag :issuing_stock_log
  test "query issuing stock log" do
    StarkInfra.IssuingStock.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :issuing_stock_log
  test "query! issuing stock log" do
    StarkInfra.IssuingStock.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :issuing_stock_log
  test "query! issuing stock log with filters" do
    stocks = StarkInfra.IssuingStock.query!(limit: 10)
    |> Enum.take(1)
    |> hd()

    StarkInfra.IssuingStock.Log.query!(limit: 1, stock_ids: [stocks.id], types: "created")
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :issuing_stock_log
  test "page issuing stock log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingStock.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_stock_log
  test "page! issuing stock log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingStock.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
