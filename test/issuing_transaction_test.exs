defmodule StarkInfraTest.IssuingTransaction do
    use ExUnit.Case

    @tag :issuing_transaction
    test "query issuing transaction test" do
        issuing_transactions = StarkInfra.IssuingTransaction.query(limit: 10)
            |> Enum.take(10)

        Enum.each(issuing_transactions, fn transaction ->
            {:ok, transaction} = transaction
            assert transaction.id == StarkInfra.IssuingTransaction.get!(transaction.id).id
        end)

        assert length(issuing_transactions) <= 10
    end

    @tag :issuing_transaction
    test "query! issuing transaction test" do
        issuing_transactions = StarkInfra.IssuingTransaction.query!(limit: 10)
            |> Enum.take(10)

        Enum.each(issuing_transactions, fn transaction ->
            assert transaction.id == StarkInfra.IssuingTransaction.get!(transaction.id).id
        end)

        assert length(issuing_transactions) <= 10
    end

    @tag :issuing_transaction
    test "page issuing transaction test" do
        {:ok, {_cursor, issuing_transactions}} = StarkInfra.IssuingTransaction.page(limit: 10)

        Enum.each(issuing_transactions, fn transaction ->
            assert transaction.id == StarkInfra.IssuingTransaction.get!(transaction.id).id
        end)

        assert length(issuing_transactions) <= 10
    end

    @tag :issuing_transaction
    test "page! issuing transaction test" do
        {_cursor, issuing_transactions} = StarkInfra.IssuingTransaction.page!(limit: 10)

        Enum.each(issuing_transactions, fn transaction ->
            assert transaction.id == StarkInfra.IssuingTransaction.get!(transaction.id).id
        end)

        assert length(issuing_transactions) <= 10
    end
end
