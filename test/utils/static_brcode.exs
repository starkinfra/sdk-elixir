defmodule StarkInfraTest.Utils.StaticBrcode do
  use ExUnit.Case

  # used only when the workspace has no PixKey registered yet
  @fallback_key_id "a4ea0a80-8443-4de0-b6c6-b1a7a63a5f1e"

  def example_key_id() do
    case StarkInfra.PixKey.query!(limit: 1) |> Enum.take(1) do
      [pix_key] -> pix_key.id
      [] -> @fallback_key_id
    end
  end

  def generate_example_static_brcode() do
    %StarkInfra.StaticBrcode{
      name: "Jamie Lannister",
      key_id: example_key_id(),
      city: "Rio de Janeiro",
      amount: 100,
      reconciliation_id: random_alphanumeric(12),
      tags: ["test"]
    }
  end

  # used by the BrcodePreview tests (PR #9): mints a StaticBrcode and returns its id, the BR code payload
  def create_id(key_id) do
    [brcode] =
      StarkInfra.StaticBrcode.create!([
        %StarkInfra.StaticBrcode{name: "Tony Stark", key_id: key_id, city: "Sao Paulo"}
      ])

    brcode.id
  end

  # ReconciliationId only accepts letters and numbers, unlike Random.random_string/1
  # (which is url-safe base64 and may contain "-"/"_").
  defp random_alphanumeric(length) do
    for _ <- 1..length, into: "", do: <<Enum.random(~c"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")>>
  end
end
