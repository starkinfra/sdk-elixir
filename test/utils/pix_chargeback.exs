defmodule StarkInfraTest.Utils.PixChargeback do
    use ExUnit.Case

    def generate_example_pix_chargeback do
        request = StarkInfra.PixRequest.query!(limit: 1) |> Enum.take(1) |> hd()

        %StarkInfra.PixChargeback{
            amount: request.amount,
            reference_id: request.end_to_end_id,
            reason: "flaw"
        }
    end
end
