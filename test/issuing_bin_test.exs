defmodule StarkInfraTest.IssuingBin do
    use ExUnit.Case

    @tag :issuing_bin
    test "query issuing bin" do
        {:ok, issuing_bin} = StarkInfra.IssuingBin.query(limit: 10)
            |> Enum.take(1)
            |> hd

        assert !is_nil(issuing_bin.id)
    end

    @tag :issuing_bin
    test "query! issuing bin" do
        issuing_bin = StarkInfra.IssuingBin.query!(limit: 10)
            |> Enum.take(1)
            |> hd

        assert !is_nil(issuing_bin.id)
    end

    @tag :issuing_bin
    test "page issuing bin" do
        {:ok, {_cursor, issuings_bin}} = StarkInfra.IssuingBin.page(limit: 10)
        issuing_bin = issuings_bin |> Enum.take(1) |> hd

        assert !is_nil(issuing_bin.id)
    end

    @tag :issuing_bin
    test "page! issuing bin" do
        {nil, issuings_bin} = StarkInfra.IssuingBin.page!(limit: 10)
        issuing_bin = issuings_bin |> Enum.take(1) |> hd

        assert !is_nil(issuing_bin.id)
    end
end
