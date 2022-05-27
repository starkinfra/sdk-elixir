defmodule StarkInfraTest.PixChargeback.Log do
    use ExUnit.Case

    @tag :pix_chargeback_log
    test "get pix chargeback log" do
        log =
            StarkInfra.PixChargeback.Log.query!(limit: 1)
            |> Enum.take(1)
            |> hd()

        {:ok, unique_log} = StarkInfra.PixChargeback.Log.get(log.id)
        assert unique_log.id == log.id
    end

    @tag :pix_chargeback_log
    test "get! pix chargeback log" do
        log =
            StarkInfra.PixChargeback.Log.query!(limit: 1)
            |> Enum.take(1)
            |> hd()

        unique_log = StarkInfra.PixChargeback.Log.get!(log.id)
        assert unique_log.id == log.id
    end

    @tag :pix_chargeback_log
    test "query pix chargeback log" do
        StarkInfra.PixChargeback.Log.query(limit: 101)
        |> Enum.take(200)
        |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :pix_chargeback_log
    test "query! pix chargeback log" do
        StarkInfra.PixChargeback.Log.query!(limit: 101)
        |> Enum.take(200)
        |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :pix_chargeback_log
    test "page pix chargeback log" do
        {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixChargeback.Log.page/1, 2, limit: 5)
        assert length(ids) <= 10
    end

    @tag :pix_chargeback_log
    test "page! pix chargeback log" do
        ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixChargeback.Log.page!/1, 2, limit: 5)
        assert length(ids) <= 10
    end    
end
