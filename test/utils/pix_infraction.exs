defmodule StarkInfraTest.Utils.PixInfraction do
  use ExUnit.Case

  def example_pix_infraction() do
    pix = StarkInfraTest.Utils.EndToEndId.get_end_to_end_id_to_infraction([], nil) |> hd
    [%StarkInfra.PixInfraction{reference_id: pix.end_to_end_id, type: "fraud"}]
  end
end
