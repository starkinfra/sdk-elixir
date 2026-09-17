defmodule StarkInfraTest.PixInternalTransactionReport.Log do
  use ExUnit.Case

  @tag :pix_internal_transaction_report_log
  test "get pix internal transaction report log" do
    log =
      StarkInfra.PixInternalTransactionReport.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, unique_log} = StarkInfra.PixInternalTransactionReport.Log.get(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_internal_transaction_report_log
  test "get! pix internal transaction report log" do
    log =
      StarkInfra.PixInternalTransactionReport.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    unique_log = StarkInfra.PixInternalTransactionReport.Log.get!(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_internal_transaction_report_log
  test "query pix internal transaction report log" do
    StarkInfra.PixInternalTransactionReport.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_internal_transaction_report_log
  test "query! pix internal transaction report log" do
    StarkInfra.PixInternalTransactionReport.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_internal_transaction_report_log
  test "page pix internal transaction report log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixInternalTransactionReport.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_internal_transaction_report_log
  test "page! pix internal transaction report log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixInternalTransactionReport.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
