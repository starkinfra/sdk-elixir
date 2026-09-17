defmodule StarkInfraTest.IssuingRestock do
  use ExUnit.Case

  @tag :issuing_restock
  test "create issuing restock" do
    {:ok, restocks} = StarkInfra.IssuingRestock.create([example_issuing_restock()])
    restock = restocks |> hd
    assert !is_nil(restock.id)
  end

  @tag :issuing_restock
  test "create! issuing restock" do
    restock = StarkInfra.IssuingRestock.create!([example_issuing_restock()]) |> hd
    assert !is_nil(restock.id)
  end

  @tag :issuing_restock
  test "get issuing restock" do
    restock =
      StarkInfra.IssuingRestock.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, retrieved_restock} = StarkInfra.IssuingRestock.get(restock.id)
    assert restock.id == retrieved_restock.id
  end

  @tag :issuing_restock
  test "get! issuing restock" do
    restock =
      StarkInfra.IssuingRestock.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    assert restock.id == StarkInfra.IssuingRestock.get!(restock.id).id
  end

  @tag :issuing_restock
  test "query issuing restock" do
    StarkInfra.IssuingRestock.query(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_restock
  test "query! issuing restock" do
    StarkInfra.IssuingRestock.query!(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_restock
  test "page issuing restock" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingRestock.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_restock
  test "page! issuing restock" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingRestock.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  def example_issuing_restock() do
    stock =
      StarkInfra.IssuingStock.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    %StarkInfra.IssuingRestock{
      count: 1,
      stock_id: stock.id,
      tags: ["card", "corporate"]
    }
  end
end
