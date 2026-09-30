defmodule StarkInfra.Utils.BacenId do
  def create(bank_code, date_format \\ "%Y%m%d%H%M") do
    [bank_code, Calendar.strftime(DateTime.utc_now, date_format), random_alphanumeric(11)]
    |> Enum.join("")
  end

  defp random_alphanumeric(length) do
    for _ <- 1..length, into: "", do: << Enum.random('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYZ') >>
  end
end
