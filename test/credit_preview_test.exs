defmodule StarkInfraTest.CreditPreview do
  use ExUnit.Case

  @tag :credit_preview
  test "create credit preview" do
    {:ok, previews} = StarkInfra.CreditPreview.create([example_credit_preview()])
    preview = previews |> hd

    assert !is_nil(preview.credit)
  end

  @tag :credit_preview
  test "create! credit preview" do
    preview = StarkInfra.CreditPreview.create!([example_credit_preview()]) |> hd

    assert !is_nil(preview.credit)
  end

  def example_credit_preview() do
    %StarkInfra.CreditPreview{
      type: "credit-note",
      credit: %StarkInfra.CreditPreview.CreditNotePreview{
        type: "sac",
        nominal_amount: 100000,
        scheduled: Date.utc_today |> Date.add(3) |> Date.to_string,
        tax_id: "012.345.678-90",
        initial_due: Date.utc_today |> Date.add(33) |> Date.to_string,
        nominal_interest: 10,
        count: 12,
        interval: "month"
      }
    }
  end
end
