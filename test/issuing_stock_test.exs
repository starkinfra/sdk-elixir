defmodule StarkInfraTest.IssuingStock do
  use ExUnit.Case

  @tag :issuing_stock
  test "query issuing stock" do
    StarkInfra.IssuingStock.query(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_stock
  test "query! issuing stock" do
    StarkInfra.IssuingStock.query!(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_stock
  test "get issuing stock" do
    StarkInfra.IssuingStock.query!(limit: 1)
    |> Enum.take(1)
    |> Enum.each(fn stock ->
      {:ok, retrieved_stock} = StarkInfra.IssuingStock.get(stock.id)
      assert stock.id == retrieved_stock.id
    end)
  end

  @tag :issuing_stock
  test "get! issuing stock" do
    StarkInfra.IssuingStock.query!(limit: 1)
    |> Enum.take(1)
    |> Enum.each(fn stock ->
      assert stock.id == StarkInfra.IssuingStock.get!(stock.id).id
    end)
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
