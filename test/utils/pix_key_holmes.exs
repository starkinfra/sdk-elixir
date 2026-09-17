defmodule StarkInfraTest.Utils.PixKeyHolmes do
  use ExUnit.Case

  def generate_example_pix_key_holmes() do
    pix_key =
      StarkInfra.PixKey.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    %StarkInfra.PixKeyHolmes{
      key_id: pix_key.id,
      tags: ["sherlock"]
    }
  end
end
