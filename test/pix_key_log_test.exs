defmodule StarkInfraTest.PixKey.Log do
  use ExUnit.Case

  @tag :pix_key_log
  test "get pix key log" do
    log =
      StarkInfra.PixKey.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, unique_log} = StarkInfra.PixKey.Log.get(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_key_log
  test "get! pix key log" do
    log =
      StarkInfra.PixKey.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    unique_log = StarkInfra.PixKey.Log.get!(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_key_log
  test "query pix key log" do
    StarkInfra.PixKey.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_key_log
  test "query! pix key log" do
    StarkInfra.PixKey.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_key_log
  test "query! pix key log with filters" do
    pix_key = StarkInfra.PixKey.query!(limit: 1)
    |> Enum.take(1)
    |> hd()

    StarkInfra.PixKey.Log.query!(limit: 1, key_ids: [pix_key.id])
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :pix_key_log
  test "page pix key log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixKey.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_key_log
  test "page! pix key log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixKey.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_key_log
  test "page pix key log with filters" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixKey.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
