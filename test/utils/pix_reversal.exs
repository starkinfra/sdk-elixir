defmodule StarkInfraTest.Utils.PixReversal do

  def generate_example_pix_reversal() do
    pix = StarkInfraTest.Utils.EndToEndId.get_end_to_end_id_to_reverse([], nil) |> hd
    %StarkInfra.PixReversal{
      amount: 10,
      end_to_end_id: pix.end_to_end_id,
      external_id: random_string(32),
      reason: "bankError"
    }
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end
