defmodule StarkInfraTest.BrcodePreview do
  use ExUnit.Case

  @tag :brcode_preview
  test "create brcode preview" do
    {:ok, previews} = StarkInfra.BrcodePreview.create([example_brcode_preview()])
    preview = previews |> hd

    assert !is_nil(preview.id)
  end

  @tag :brcode_preview
  test "create! brcode preview" do
    preview =
      StarkInfra.BrcodePreview.create!([example_brcode_preview()])
      |> hd

    assert !is_nil(preview.id)
  end

  def example_brcode_preview() do
    %StarkInfra.BrcodePreview{
      id: StarkInfraTest.Utils.StaticBrcode.create_id("+5511989890096"),
      payer_id: "20.018.183/0001-80"
    }
  end
end
