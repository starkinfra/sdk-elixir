defmodule StarkInfraTest.IssuingToken.Log do
  use ExUnit.Case

  # The sandbox project used in this test suite has no IssuingToken records, so there are no
  # IssuingToken.Log entries to retrieve either. query/page are expected to return empty results.

  @tag :issuing_token_log
  test "query issuing token log test" do
    logs = StarkInfra.IssuingToken.Log.query(limit: 10) |> Enum.take(10)
    assert logs == []
  end

  @tag :issuing_token_log
  test "query! issuing token log test" do
    logs = StarkInfra.IssuingToken.Log.query!(limit: 10) |> Enum.take(10)
    assert logs == []
  end

  @tag :issuing_token_log
  test "page issuing token log test" do
    {:ok, {cursor, logs}} = StarkInfra.IssuingToken.Log.page(limit: 10)
    assert logs == []
    assert is_nil(cursor)
  end

  @tag :issuing_token_log
  test "page! issuing token log test" do
    {cursor, logs} = StarkInfra.IssuingToken.Log.page!(limit: 10)
    assert logs == []
    assert is_nil(cursor)
  end
end
