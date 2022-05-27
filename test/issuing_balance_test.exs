defmodule StarkInfraTest.IssuingBalance do
    use ExUnit.Case

    @tag :issuing_balance
    test "get issuing balance test" do
        {:ok, issuing_balance} = StarkInfra.IssuingBalance.get()

        assert !is_nil(issuing_balance.id)
    end

    @tag :issuing_balance
    test "get! issuing balance test" do
        issuing_balance = StarkInfra.IssuingBalance.get!()

        assert !is_nil(issuing_balance.id)
    end
end
