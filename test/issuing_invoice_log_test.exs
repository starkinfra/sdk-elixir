defmodule StarkInfraTest.IssuingInvoice.Log do
    use ExUnit.Case

    @tag :issuing_invoice_log
    test "get issuing invoice log" do
        logs = StarkInfra.IssuingInvoice.Log.query!(limit: 10)
            |> Enum.take(1)
            |> hd

        {:ok, log} = StarkInfra.IssuingInvoice.Log.get(logs.id)

        assert logs.id == log.id
    end

    @tag :issuing_invoice_log
    test "get! issuing invoice log" do
        logs = StarkInfra.IssuingInvoice.Log.query!(limit: 10)
            |> Enum.take(1)
            |> hd

        log = StarkInfra.IssuingInvoice.Log.get!(logs.id)

        assert logs.id == log.id
    end

    @tag :issuing_invoice_log
    test "query issuing invoice log" do
        StarkInfra.IssuingInvoice.Log.query(limit: 101)
            |> Enum.take(200)
            |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :issuing_invoice_log
    test "query! issuing invoice log" do
        StarkInfra.IssuingInvoice.Log.query!(limit: 1)
            |> Enum.take(5)
            |> (fn list -> assert length(list) == 1 end).()
    end

    @tag :issuing_invoice_log
    test "page issuing invoice log" do
            {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingInvoice.Log.page/1, 2, limit: 5)
            assert length(ids) <= 10
    end

    @tag :issuing_invoice_log
    test "page! issuing invoice log" do
            ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingInvoice.Log.page!/1, 2, limit: 5)
            assert length(ids) <= 10
    end
end
