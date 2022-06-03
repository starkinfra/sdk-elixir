defmodule StarkInfra.Utils.BacenId do
  def create(bank_code) do
    [bank_code, datetime_to_string(DateTime.utc_now), random_alphanumeric(11)]
    |> Enum.join("")
  end

  defp datetime_to_string(datetime) do
    [datetime.year, datetime.month, datetime.day, datetime.hour, datetime.minute]
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.pad_leading(&1, 2, "0"))
    |> Enum.join("")
  end

  defp random_alphanumeric(length) do
    for _ <- 1..length, into: "", do: << Enum.random('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYZ') >>
  end
end
