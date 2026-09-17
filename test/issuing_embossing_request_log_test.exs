defmodule StarkInfraTest.IssuingEmbossingRequest.Log do
  use ExUnit.Case

  @tag :issuing_embossing_request_log
  test "get issuing embossing request log" do
    log =
      StarkInfra.IssuingEmbossingRequest.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkInfra.IssuingEmbossingRequest.Log.get(log.id)
  end

  @tag :issuing_embossing_request_log
  test "get! issuing embossing request log" do
    log =
      StarkInfra.IssuingEmbossingRequest.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    _log = StarkInfra.IssuingEmbossingRequest.Log.get!(log.id)
  end

  @tag :issuing_embossing_request_log
  test "query issuing embossing request log" do
    StarkInfra.IssuingEmbossingRequest.Log.query(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_embossing_request_log
  test "query! issuing embossing request log" do
    StarkInfra.IssuingEmbossingRequest.Log.query!(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_embossing_request_log
  test "page issuing embossing request log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingEmbossingRequest.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_embossing_request_log
  test "page! issuing embossing request log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingEmbossingRequest.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
