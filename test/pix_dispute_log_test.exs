defmodule StarkInfraTest.PixDispute.Log do
  use ExUnit.Case

  @tag :pix_dispute_log
  test "get pix dispute log" do
    log =
      StarkInfra.PixDispute.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, unique_log} = StarkInfra.PixDispute.Log.get(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_dispute_log
  test "get! pix dispute log" do
    log =
      StarkInfra.PixDispute.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    unique_log = StarkInfra.PixDispute.Log.get!(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_dispute_log
  test "query pix dispute log" do
    StarkInfra.PixDispute.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_dispute_log
  test "query! pix dispute log" do
    StarkInfra.PixDispute.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_dispute_log
  test "page pix dispute log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixDispute.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_dispute_log
  test "page! pix dispute log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixDispute.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
