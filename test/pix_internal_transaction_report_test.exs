defmodule StarkInfraTest.PixInternalTransactionReport do
  use ExUnit.Case

  @tag :pix_internal_transaction_report
  test "create pix internal transaction report" do
    {:ok, reports} = StarkInfra.PixInternalTransactionReport.create([StarkInfraTest.Utils.PixInternalTransactionReport.generate_example_pix_internal_transaction_report()])
    report = reports |> hd
    assert !is_nil(report.id)
  end

  @tag :pix_internal_transaction_report
  test "create! pix internal transaction report" do
    report = StarkInfra.PixInternalTransactionReport.create!([StarkInfraTest.Utils.PixInternalTransactionReport.generate_example_pix_internal_transaction_report()]) |> hd
    assert !is_nil(report.id)
  end

  @tag :pix_internal_transaction_report
  test "get pix internal transaction report" do
    pix_internal_transaction_report =
      StarkInfra.PixInternalTransactionReport.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, report} = StarkInfra.PixInternalTransactionReport.get(pix_internal_transaction_report.id)

    assert !is_nil(report.id)
  end

  @tag :pix_internal_transaction_report
  test "get! pix internal transaction report" do
    pix_internal_transaction_report =
      StarkInfra.PixInternalTransactionReport.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    report = StarkInfra.PixInternalTransactionReport.get!(pix_internal_transaction_report.id)

    assert !is_nil(report.id)
  end

  @tag :pix_internal_transaction_report
  test "query pix internal transaction report" do
    StarkInfra.PixInternalTransactionReport.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_internal_transaction_report
  test "query! pix internal transaction report" do
    StarkInfra.PixInternalTransactionReport.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_internal_transaction_report
  test "page pix internal transaction report" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixInternalTransactionReport.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_internal_transaction_report
  test "page! pix internal transaction report" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixInternalTransactionReport.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
