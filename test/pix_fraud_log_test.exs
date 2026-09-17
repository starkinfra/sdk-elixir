defmodule StarkInfraTest.PixFraud.Log do
  use ExUnit.Case

  @tag :pix_fraud_log
  test "get pix fraud log" do
    log =
      StarkInfra.PixFraud.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, unique_log} = StarkInfra.PixFraud.Log.get(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_fraud_log
  test "get! pix fraud log" do
    log =
      StarkInfra.PixFraud.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    unique_log = StarkInfra.PixFraud.Log.get!(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_fraud_log
  test "query pix fraud log" do
    StarkInfra.PixFraud.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_fraud_log
  test "query! pix fraud log" do
    StarkInfra.PixFraud.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_fraud_log
  test "page pix fraud log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixFraud.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_fraud_log
  test "page! pix fraud log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixFraud.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
