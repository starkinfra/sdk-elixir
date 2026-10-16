defmodule StarkInfra.Utils.PixSubscriptionBacenId do
  @doc """
  Generates a random Pix subscription bacenId based on your bank code (ISPB), used as the
  bacen_id of a PixPullSubscription. The date part is always generated in UTC, regardless of
  the machine timezone.

  ## Parameters (required):
    - `bank_code` [string]: your bank code (ISPB). ex: "20018183"
    - `prefix` [string]: subscription prefix. ex: "RR"

  ## Return:
    - 29-character bacenId composed of the prefix, the bank code, the current UTC date (yyyyMMdd) and 11 random alphanumeric characters. ex: "RR2001818320261016aB3xK9mQ2wZ"
  """
  def create(bank_code, prefix) do
    [prefix, StarkInfra.Utils.BacenId.create(bank_code, "%Y%m%d")]
    |> Enum.join("")
  end
end
