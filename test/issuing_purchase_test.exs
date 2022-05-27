defmodule StarkInfraTest.IssuingPurchase do
    use ExUnit.Case

    @tag :issuing_purchase
    test "query issuing purchase test" do
        issuing_purchases = StarkInfra.IssuingPurchase.query(limit: 10)
            |> Enum.take(10)

        Enum.each(issuing_purchases, fn purchase ->
            {:ok, purchase} = purchase
            assert purchase.id == StarkInfra.IssuingPurchase.get!(purchase.id).id
        end)

        assert length(issuing_purchases) <= 10
    end

    @tag :issuing_purchase
    test "query! issuing purchase test" do
        issuing_purchases = StarkInfra.IssuingPurchase.query!(limit: 10)
            |> Enum.take(10)

        Enum.each(issuing_purchases, fn purchase ->
            assert purchase.id == StarkInfra.IssuingPurchase.get!(purchase.id).id
        end)

        assert length(issuing_purchases) <= 10
    end

    @tag :issuing_purchase
    test "page issuing purchase test" do
        {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingPurchase.page/1, 2, limit: 5)
        assert length(ids) <= 10

        Enum.each(ids, fn id ->
            {:ok, purchase} = StarkInfra.IssuingPurchase.get(id)
            assert purchase.id == id
        end)

    end

    @tag :issuing_purchase
    test "page! issuing purchase test" do
        ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingPurchase.page!/1, 2, limit: 5)
        assert length(ids) <= 10

        Enum.each(ids, fn id ->
            assert id == StarkInfra.IssuingPurchase.get!(id).id
        end)
    end
end
