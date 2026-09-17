defmodule StarkInfraTest.Utils.PixDispute do
  use ExUnit.Case

  def generate_example_pix_dispute do
    disputed =
      StarkInfra.PixDispute.query!(limit: 100)
      |> Enum.map(fn dispute -> dispute.reference_id end)
      |> MapSet.new()

    {_cursor, requests} = StarkInfra.PixRequest.page!(limit: 100, status: "success")

    # a reference can only be disputed once, so skip the ones already used
    request =
      requests
      |> Enum.filter(fn request -> request.flow == "out" and not MapSet.member?(disputed, request.end_to_end_id) end)
      |> Enum.random()

    %StarkInfra.PixDispute{
      reference_id: request.end_to_end_id,
      method: "scam",
      operator_email: "operator@example.com",
      operator_phone: "+5511989898989"
    }
  end
end
