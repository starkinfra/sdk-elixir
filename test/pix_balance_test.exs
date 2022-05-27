defmodule StarkInfraTest.PixBalance do
    use ExUnit.Case

    @tag :pix_balance
    test "get pix balance" do
        {:ok, pix_balance} = StarkInfra.PixBalance.get()

        assert !is_nil(pix_balance.id)
    end

    @tag :pix_balance
    test "get! pix balance" do
        pix_balance = StarkInfra.PixBalance.get!()

        assert !is_nil(pix_balance.id)
    end
end
