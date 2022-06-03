defmodule StarkInfra.Utils.ReturnId do
  def create(bank_code) do
    ["D", StarkInfra.Utils.BacenId.create(bank_code)]
    |> Enum.join("")
  end
end
