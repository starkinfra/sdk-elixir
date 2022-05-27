defmodule StarkInfraTest.PixReversal.Log do
    use ExUnit.Case

    @tag :pix_reversal_log
    test "get pix reversal log" do
        log = StarkInfra.PixReversal.Log.query!(limit: 1)
            |> Enum.take(1)
            |> hd()

        {:ok, unique_log} = StarkInfra.PixReversal.Log.get(log.id)
        assert unique_log.id == log.id
    end

    @tag :pix_reversal_log
    test "get! pix reversal log" do
        log = StarkInfra.PixReversal.Log.query!(limit: 1)
            |> Enum.take(1)
            |> hd()

        unique_log = StarkInfra.PixReversal.Log.get!(log.id)
        assert unique_log.id == log.id
    end

    @tag :pix_reversal_log
    test "query pix reversal log" do
        StarkInfra.PixReversal.Log.query(limit: 101)
            |> Enum.take(200)
            |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :pix_reversal_log
    test "query! pix reversal log" do
        StarkInfra.PixReversal.Log.query!(limit: 101)
            |> Enum.take(200)
            |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :pix_reversal_log
    test "query! pix reversal log with filters" do
        pix_reversal = StarkInfra.PixReversal.query!(limit: 1)
            |> Enum.take(1)
            |> hd()

        StarkInfra.PixReversal.Log.query!(limit: 1, reversal_ids: [pix_reversal.id])
        |> Enum.take(5)
        |> (fn list -> assert length(list) == 1 end).()
    end

    @tag :pix_reversal_log
    test "page pix reversal log" do
        {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixReversal.Log.page/1, 2, limit: 5)
        assert length(ids) <= 10
    end

    @tag :pix_reversal_log
    test "page! pix reversal log" do
        ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixReversal.Log.page!/1, 2, limit: 5)
        assert length(ids) <= 10
    end

    @tag :pix_reversal_log
    test "page pix reversal log with filters" do
        pix_reversal = StarkInfra.PixReversal.query!(limit: 5)
            |> Enum.take(1)
            |> hd()

        {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixReversal.Log.page/1, 2, limit: 5, reversal_ids: [pix_reversal.id])
        assert length(ids) <= 10
    end

    @tag :pix_reversal_loga
    test "page! pix reversal log with filters" do
        pix_reversal = StarkInfra.PixReversal.query!(limit: 10)
            |> Enum.take(1)
            |> hd()

        ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixReversal.Log.page!/1, 1, limit: 5, reversal_ids: [pix_reversal.id])
        assert length(ids) <= 10
    end

    @tag :pix_reversal_log
    test "page pix reversal log with filters and order" do
        pix_reversal = StarkInfra.PixReversal.query!(limit: 5)
            |> Enum.take(1)
            |> hd()

        {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixReversal.Log.page/1, 2, limit: 5, reversal_ids: [pix_reversal.id])
        assert length(ids) <= 10
    end
end
