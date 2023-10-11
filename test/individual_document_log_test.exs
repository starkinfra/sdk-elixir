defmodule StarkInfraTest.IndividualDocument.Log do
  use ExUnit.Case

  @tag :individual_document_log
  test "get individual document log" do
    log =
      StarkInfra.IndividualDocument.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkInfra.IndividualDocument.Log.get(log.id)
  end

  @tag :individual_document_log
  test "get! individual document log" do
    log =
      StarkInfra.IndividualDocument.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    _log = StarkInfra.IndividualDocument.Log.get!(log.id)
  end

  @tag :individual_document_log
  test "query individual document log" do
    StarkInfra.IndividualDocument.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_document_log
  test "query! individual document log" do
    StarkInfra.IndividualDocument.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_document_log
  test "query! individual document log with filters" do
    documents = StarkInfra.IndividualDocument.query!(status: "created")
    |> Enum.take(1)
    |> hd()

    StarkInfra.IndividualDocument.Log.query!(limit: 1, document_ids: [documents.id], types: "created")
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :individual_document_log
  test "page individual document log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IndividualDocument.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :individual_document_log
  test "page! individual document log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IndividualDocument.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
