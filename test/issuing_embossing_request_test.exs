defmodule StarkInfraTest.IssuingEmbossingRequest do
  use ExUnit.Case

  @tag :issuing_embossing_request
  test "get issuing embossing request" do
    request =
      StarkInfra.IssuingEmbossingRequest.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, _request} = StarkInfra.IssuingEmbossingRequest.get(request.id)
  end

  @tag :issuing_embossing_request
  test "get! issuing embossing request" do
    request =
      StarkInfra.IssuingEmbossingRequest.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    _request = StarkInfra.IssuingEmbossingRequest.get!(request.id)
  end

  @tag :issuing_embossing_request
  test "query issuing embossing request" do
    StarkInfra.IssuingEmbossingRequest.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :issuing_embossing_request
  test "query! issuing embossing request" do
    StarkInfra.IssuingEmbossingRequest.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :issuing_embossing_request
  test "query! issuing embossing request with filters" do
    StarkInfra.IssuingEmbossingRequest.query!(status: "success")
    |> Enum.take(1)
  end

  @tag :issuing_embossing_request
  test "page issuing embossing request" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingEmbossingRequest.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_embossing_request
  test "page! issuing embossing request" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingEmbossingRequest.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
