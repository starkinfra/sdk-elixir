defmodule StarkInfraTest.PixReversal do
    use ExUnit.Case

    @tag :pix_reversal
    test "create pix reversal" do
        {:ok, reversals} = StarkInfra.PixReversal.create([
            StarkInfraTest.Utils.PixReversal.generate_example_pix_reversal()
        ])
        reversal = reversals |> hd

        assert !is_nil(reversal.id)
    end

    @tag :pix_reversal
    test "create! pix reversal" do
        pix_reversal = StarkInfra.PixReversal.create!([
            StarkInfraTest.Utils.PixReversal.generate_example_pix_reversal()
        ]) |> hd
        assert !is_nil(pix_reversal.id)
    end

    @tag :pix_reversal
    test "get pix reversal" do
        pix_reversal = StarkInfra.PixReversal.query!(limit: 100)
            |> Enum.take(1)
            |> hd()

        {:ok, reversal} = StarkInfra.PixReversal.get(pix_reversal.id)
        assert !is_nil(reversal.id)
    end

    @tag :pix_reversal
    test "get! pix reversal" do
        pix_reversal = StarkInfra.PixReversal.query!(limit: 100)
            |> Enum.take(1)
            |> hd

        reversal = StarkInfra.PixReversal.get!(pix_reversal.id)

        assert !is_nil(reversal.id)
    end

    @tag :pix_reversal
    test "query pix reversal" do
        StarkInfra.PixReversal.query!(limit: 101, before: DateTime.utc_now())
            |> Enum.take(200)
            |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :pix_reversal
    test "query! pix reversal" do
        StarkInfra.PixReversal.query!(limit: 101, before: DateTime.utc_now())
            |> Enum.take(200)
            |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :pix_reversal
    test "page pix reversal" do
        {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixReversal.page/1, 2, limit: 5)
        assert length(ids) <= 10
    end

    @tag :pix_reversal
    test "page! pix reversal" do
        {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixReversal.page/1, 2, limit: 5)
        assert length(ids) <= 10
    end
end
