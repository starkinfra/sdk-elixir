defmodule StarkInfraTest.PixKeyHolmes.Log do
  use ExUnit.Case

  @tag :pix_key_holmes_log
  test "get pix key holmes log" do
    log =
      StarkInfra.PixKeyHolmes.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, unique_log} = StarkInfra.PixKeyHolmes.Log.get(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_key_holmes_log
  test "get! pix key holmes log" do
    log =
      StarkInfra.PixKeyHolmes.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    unique_log = StarkInfra.PixKeyHolmes.Log.get!(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_key_holmes_log
  test "query pix key holmes log" do
    StarkInfra.PixKeyHolmes.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_key_holmes_log
  test "query! pix key holmes log" do
    StarkInfra.PixKeyHolmes.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_key_holmes_log
  test "page pix key holmes log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixKeyHolmes.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_key_holmes_log
  test "page! pix key holmes log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixKeyHolmes.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
