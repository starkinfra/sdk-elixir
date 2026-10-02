defmodule StarkInfra.Utils.PixSubscriptionBacenId do
  def create(bank_code, prefix) do
    [prefix, StarkInfra.Utils.BacenId.create(bank_code, "%Y%m%d")]
    |> Enum.join("")
  end
end
