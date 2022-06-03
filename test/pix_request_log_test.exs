defmodule StarkInfraTest.PixRequest.Log do
  use ExUnit.Case

  @tag :pix_request_log
  test "get pix request log" do
    log =
      StarkInfra.PixRequest.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, unique_log} = StarkInfra.PixRequest.Log.get(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_request_log
  test "get! pix request log" do
    log =
      StarkInfra.PixRequest.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    unique_log = StarkInfra.PixRequest.Log.get!(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_request_log
  test "query pix request log" do
    StarkInfra.PixRequest.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_request_log
  test "query! pix request log" do
    StarkInfra.PixRequest.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_request_log
  test "query! pix request log with filters" do
    pix_request = StarkInfra.PixRequest.query!(limit: 1)
    |> Enum.take(1)
    |> hd()

    StarkInfra.PixRequest.Log.query!(limit: 1, request_ids: [pix_request.id])
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :pix_request_log
  test "page pix request log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixRequest.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_request_log
  test "page! pix request log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixRequest.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
