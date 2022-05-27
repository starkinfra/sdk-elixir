defmodule StarkInfraTest.Utils.IssuingWithdrawal do
    use ExUnit.Case

    def random_string(length) do
        for _ <- 1..length, into: "", do: <<Enum.random('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYZ')>>
    end

    def example_issuing_withdrawal do
        %StarkInfra.IssuingWithdrawal{
            amount: 10,
            external_id: random_string(15),
            description: "Issuing Withdrawal test"
        }
    end
end