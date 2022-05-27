defmodule StarkInfraTest.IssuingCard.Log do
    use ExUnit.Case

    @tag :issuing_card_log
    test "get issuing card log" do
        logs = StarkInfra.IssuingCard.Log.query!(limit: 10)
        |> Enum.take(1)
        |> hd

        {:ok, log} = StarkInfra.IssuingCard.Log.get(logs.id)

        assert logs.id == log.id
    end

    @tag :issuing_card_log
    test "get! issuing card log" do
        logs = StarkInfra.IssuingCard.Log.query!(limit: 10)
        |> Enum.take(1)
        |> hd

        log = StarkInfra.IssuingCard.Log.get!(logs.id)

        assert logs.id == log.id
    end

    @tag :issuing_card_log
    test "query issuing card log" do
        StarkInfra.IssuingCard.Log.query(limit: 101)
            |> Enum.take(200)
            |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :issuing_card_log
    test "query! issuing card log" do
        StarkInfra.IssuingCard.Log.query!(limit: 1)
            |> Enum.take(5)
            |> (fn list -> assert length(list) == 1 end).()
    end

    @tag :issuing_card_log
    test "page issuing card log" do
            {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingCard.Log.page/1, 2, limit: 5)
            assert length(ids) <= 10
    end

    @tag :issuing_card_log
    test "page! issuing card log" do
            ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingCard.Log.page!/1, 2, limit: 5)
            assert length(ids) <= 10
    end
end
