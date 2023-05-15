defmodule StarkInfraTest.BrcodePreview do
  use ExUnit.Case

  @tag :brcode_preview
  test "create brcode preview" do
    {:ok, previews} = StarkInfra.BrcodePreview.create([brcodes_examples()])
    preview = previews |> hd

    assert !is_nil(preview.id)
  end

  defp brcodes_examples() do
    dynamics = StarkInfra.DynamicBrcode.query!(limit: 2)
      |> Enum.take(1)
      |> hd

    %StarkInfra.BrcodePreview{
    id: dynamics.id,
    end_to_end_id: "E355477532023050423035uWBNV2BxGd",
    payer_id: "20.018.183/0001-80"
    }
  end
end
