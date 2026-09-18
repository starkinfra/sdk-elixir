defmodule StarkInfraTest.BusinessIdentity.Log do
  use ExUnit.Case

  @tag :business_identity_log
  test "get business identity log" do
    {:ok, log} = StarkInfra.BusinessIdentity.Log.get("5656565656565656")
    assert !is_nil(log.id)
  end

  @tag :business_identity_log
  test "get! business identity log" do
    log = StarkInfra.BusinessIdentity.Log.get!("5656565656565656")
    assert !is_nil(log.id)
  end

  @tag :business_identity_log
  test "query business identity log" do
    StarkInfra.BusinessIdentity.Log.query!(limit: 1)
    |> Enum.take(1)
    |> (fn list -> assert length(list) <= 1 end).()
  end

  @tag :business_identity_log
  test "query! business identity log" do
    StarkInfra.BusinessIdentity.Log.query!(limit: 1)
    |> Enum.take(1)
    |> (fn list -> assert length(list) <= 1 end).()
  end

  @tag :business_identity_log
  test "page business identity log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.BusinessIdentity.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :business_identity_log
  test "page! business identity log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.BusinessIdentity.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
