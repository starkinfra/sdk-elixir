defmodule StarkInfraTest.IssuingRestock do
  use ExUnit.Case

  @tag :issuing_restock
  test "get issuing restock" do
    issuing_restock =
      StarkInfra.IssuingRestock.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, restock} = StarkInfra.IssuingRestock.get(issuing_restock.id)

    assert !is_nil(restock.id)
  end

  @tag :issuing_restock
  test "get! issuing restock" do
    issuing_restock =
      StarkInfra.IssuingRestock.query!(limit: 1)
      |> Enum.take(1)
      |> hd()
    restock = StarkInfra.IssuingRestock.get!(issuing_restock.id)

    assert !is_nil(restock.id)
  end

  @tag :issuing_restock
  test "query issuing restock" do
    StarkInfra.IssuingRestock.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :issuing_restock
  test "query! issuing restock" do
    StarkInfra.IssuingRestock.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
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

  @tag :issuing_restock
  test "create issuing restock" do
    {:ok, restocks} = StarkInfra.IssuingRestock.create([example_issuing_restock()])
    restock = restocks |> hd

    assert !is_nil(restock.id)
  end

  @tag :issuing_restock
  test "create! issuing restock" do
    restocks = StarkInfra.IssuingRestock.create!([example_issuing_restock()])
    restock = restocks |> hd

    assert !is_nil(restock.id)
  end

  def example_issuing_restock() do
    %StarkInfra.IssuingRestock{
      count: 100000,
      stock_id: "5792731695677440"
    }
  end
end
