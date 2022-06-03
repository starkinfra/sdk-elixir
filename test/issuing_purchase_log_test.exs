defmodule StarkInfraTest.IssuingPurchase.Log do
  use ExUnit.Case

  @tag :issuing_purchase_log
  test "get issuing purchase log" do
    logs = StarkInfra.IssuingPurchase.Log.query!(limit: 10)
      |> Enum.take(1)
      |> hd

    {:ok, log} = StarkInfra.IssuingPurchase.Log.get(logs.id)

    assert logs.id == log.id
  end

  @tag :issuing_purchase_log
  test "get! issuing purchase log" do
    logs = StarkInfra.IssuingPurchase.Log.query!(limit: 10)
      |> Enum.take(1)
      |> hd

    log = StarkInfra.IssuingPurchase.Log.get!(logs.id)

    assert logs.id == log.id
  end

  @tag :issuing_purchase_log
  test "query issuing purchase log" do
    StarkInfra.IssuingPurchase.Log.query(limit: 101)
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :issuing_purchase_log
  test "page issuing purchase log" do
      {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingPurchase.Log.page/1, 2, limit: 5)
      assert length(ids) <= 10
  end

  @tag :issuing_purchase_log
  test "page! issuing purchase log" do
      ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingPurchase.Log.page!/1, 2, limit: 5)
      assert length(ids) <= 10
  end
end
