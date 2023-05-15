defmodule StarkInfraTest.IssuingStock do
  use ExUnit.Case

  @tag :issuing_stock
  test "get issuing stock" do
    log =
      StarkInfra.IssuingStock.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkInfra.IssuingStock.get(log.id)
  end

  @tag :issuing_stock
  test "get! issuing stock" do
    log =
      StarkInfra.IssuingStock.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    _log = StarkInfra.IssuingStock.get!(log.id)
  end

  @tag :issuing_stock
  test "query issuing stock" do
    StarkInfra.IssuingStock.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :issuing_stock
  test "query! issuing stock" do
    StarkInfra.IssuingStock.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :issuing_stock
  test "query! issuing stock with filters" do
    StarkInfra.IssuingStock.query!(limit: 1)
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :issuing_stock
  test "page issuing stock" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingStock.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_stock
  test "page! issuing stock" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingStock.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
