defmodule StarkInfraTest.IssuingHolder.Log do
  use ExUnit.Case

  @tag :issuing_holder_log
  test "get issuing holder log" do
    logs = StarkInfra.IssuingHolder.Log.query!(limit: 10)
      |> Enum.take(1)
      |> hd

    {:ok, log} = StarkInfra.IssuingHolder.Log.get(logs.id)
    assert logs.id == log.id
  end

  @tag :issuing_holder_log
  test "get! issuing holder log" do
    logs = StarkInfra.IssuingHolder.Log.query!(limit: 10)
      |> Enum.take(1)
      |> hd

    log = StarkInfra.IssuingHolder.Log.get!(logs.id)

    assert logs.id == log.id
  end

  @tag :issuing_holder_log
  test "query issuing holder log" do
    StarkInfra.IssuingHolder.Log.query(limit: 10)
      |> Enum.take(10)
      |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_holder_log
  test "query! issuing holder log" do
    StarkInfra.IssuingHolder.Log.query!(limit: 10)
      |> Enum.take(10)
      |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_holder_log
  test "page issuing holder log" do
      {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingHolder.Log.page/1, 2, limit: 5)
      assert length(ids) <= 10
  end

  @tag :issuing_holder_log
  test "page! issuing holder log" do
      ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingHolder.Log.page!/1, 2, limit: 5)
      assert length(ids) <= 10
  end
end
