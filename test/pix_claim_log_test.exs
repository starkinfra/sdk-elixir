defmodule StarkInfraTest.PixClaim.Log do
    use ExUnit.Case

    @tag :pix_claim_log
    test "get pix claim log" do
        log =
            StarkInfra.PixClaim.Log.query!(limit: 1)
            |> Enum.take(1)
            |> hd()

        {:ok, unique_log} = StarkInfra.PixClaim.Log.get(log.id)
        assert unique_log.id == log.id
    end

    @tag :pix_claim_log
    test "get! pix claim log" do
        log =
            StarkInfra.PixClaim.Log.query!(limit: 1)
            |> Enum.take(1)
            |> hd()

        unique_log = StarkInfra.PixClaim.Log.get!(log.id)
        assert unique_log.id == log.id
    end

    @tag :pix_claim_log
    test "query pix claim log" do
        StarkInfra.PixClaim.Log.query(limit: 101)
        |> Enum.take(200)
        |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :pix_claim_log
    test "query! pix claim log" do
        StarkInfra.PixClaim.Log.query!(limit: 101)
        |> Enum.take(200)
        |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :pix_claim_log
    test "query! pix claim log with filters" do
        pix_claim = StarkInfra.PixClaim.query!(limit: 1)
        |> Enum.take(1)
        |> hd()

        StarkInfra.PixClaim.Log.query!(claim_ids: [pix_claim.id])
        |> Enum.take(50)
        |> (fn log -> 
            log = log |> hd
            assert log.claim.id == pix_claim.id 
        end).()
    end

    @tag :pix_claim_log
    test "page pix claim log" do
        {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixClaim.Log.page/1, 2, limit: 5)
        assert length(ids) <= 10
    end

    @tag :pix_claim_log
    test "page! pix claim log" do
        ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixClaim.Log.page!/1, 2, limit: 5)
        assert length(ids) <= 10
    end
end
