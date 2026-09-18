defmodule StarkInfraTest.BusinessAttachment.Log do
  use ExUnit.Case

  @tag :business_attachment_log
  test "get business attachment log" do
    {:ok, log} = StarkInfra.BusinessAttachment.Log.get("5656565656565656")
    assert !is_nil(log.id)
  end

  @tag :business_attachment_log
  test "get! business attachment log" do
    log = StarkInfra.BusinessAttachment.Log.get!("5656565656565656")
    assert !is_nil(log.id)
  end

  @tag :business_attachment_log
  test "query business attachment log" do
    StarkInfra.BusinessAttachment.Log.query!(limit: 1)
    |> Enum.take(1)
    |> (fn list -> assert length(list) <= 1 end).()
  end

  @tag :business_attachment_log
  test "query! business attachment log" do
    StarkInfra.BusinessAttachment.Log.query!(limit: 1)
    |> Enum.take(1)
    |> (fn list -> assert length(list) <= 1 end).()
  end

  @tag :business_attachment_log
  test "page business attachment log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.BusinessAttachment.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :business_attachment_log
  test "page! business attachment log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.BusinessAttachment.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
