defmodule StarkInfra.Utils.EndToEndId do
  def create(bank_code) do
    ["E", StarkInfra.Utils.BacenId.create(bank_code)]
    |> Enum.join("")
  end
end
