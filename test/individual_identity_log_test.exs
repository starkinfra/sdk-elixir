defmodule StarkInfraTest.IndividualIdentity.Log do
  use ExUnit.Case

  @tag :individual_identity_log
  test "get individual identity log" do
    log =
      StarkInfra.IndividualIdentity.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkInfra.IndividualIdentity.Log.get(log.id)
  end

  @tag :individual_identity_log
  test "get! individual identity log" do
    log =
      StarkInfra.IndividualIdentity.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    _log = StarkInfra.IndividualIdentity.Log.get!(log.id)
  end

  @tag :individual_identity_log
  test "query individual identity log" do
    StarkInfra.IndividualIdentity.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_identity_log
  test "query! individual identity log" do
    StarkInfra.IndividualIdentity.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_identity_log
  test "query! individual identity log with filters" do
    identities = StarkInfra.IndividualIdentity.query!(status: "created")
    |> Enum.take(1)
    |> hd()

    StarkInfra.IndividualIdentity.Log.query!(limit: 1, identity_ids: [identities.id], types: "created")
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :individual_identity_log
  test "page individual identity log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IndividualIdentity.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :individual_identity_log
  test "page! individual identity log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IndividualIdentity.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
