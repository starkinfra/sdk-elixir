defmodule StarkInfraTest.IndividualIdentity.Log do
  use ExUnit.Case

  # IndividualIdentity is known to lack permission on the shared sandbox project;
  # these log tests run for real and are left to fail honestly when that happens.

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
  test "page individual identity log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IndividualIdentity.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :individual_identity_log
  test "page! individual identity log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IndividualIdentity.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :individual_identity_log
  test "get individual identity log" do
    log =
      StarkInfra.IndividualIdentity.Log.query!(limit: 1)
      |> Enum.take(1)

    assert log != [], "no IndividualIdentity log in sandbox"
    log = log |> hd()

    {:ok, unique_log} = StarkInfra.IndividualIdentity.Log.get(log.id)
    assert unique_log.id == log.id
  end

  @tag :individual_identity_log
  test "get! individual identity log" do
    log =
      StarkInfra.IndividualIdentity.Log.query!(limit: 1)
      |> Enum.take(1)

    assert log != [], "no IndividualIdentity log in sandbox"
    log = log |> hd()

    unique_log = StarkInfra.IndividualIdentity.Log.get!(log.id)
    assert unique_log.id == log.id
  end
end
