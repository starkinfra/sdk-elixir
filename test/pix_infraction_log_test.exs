defmodule StarkInfraTest.PixInfraction.Log do
    use ExUnit.Case

    @tag :pix_infraction_log
    test "get pix infraction log" do
        log =
            StarkInfra.PixInfraction.Log.query!(limit: 1)
            |> Enum.take(1)
            |> hd()

        {:ok, unique_log} = StarkInfra.PixInfraction.Log.get(log.id)
        assert unique_log.id == log.id
    end

    @tag :pix_infraction_log
    test "get! pix infraction log" do
        log =
            StarkInfra.PixInfraction.Log.query!(limit: 1)
            |> Enum.take(1)
            |> hd()

        unique_log = StarkInfra.PixInfraction.Log.get!(log.id)
        assert unique_log.id == log.id
    end

    @tag :pix_infraction_log
    test "query pix infraction log" do
        StarkInfra.PixInfraction.Log.query(limit: 101)
        |> Enum.take(200)
        |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :pix_infraction_log
    test "query! pix infraction log" do
        StarkInfra.PixInfraction.Log.query!(limit: 101)
        |> Enum.take(200)
        |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :pix_infraction_log
    test "page pix infraction log" do
        {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixInfraction.Log.page/1, 2, limit: 5)
        assert length(ids) <= 10
    end

    @tag :pix_infraction_log
    test "page! pix infraction log" do
        ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixInfraction.Log.page!/1, 2, limit: 5)
        assert length(ids) <= 10
    end
end
