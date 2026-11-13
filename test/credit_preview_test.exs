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

  @tag :credit_preview
  test "create credit preview with only nominal_amount or only amount" do
    value = Enum.random(100_000..1_000_000)
    sent = [
      amount_preview("sac", :amount, value),
      amount_preview("price", :amount, value),
      amount_preview("american", :amount, value),
      amount_preview("bullet", :amount, value),
      amount_preview("sac", :nominal_amount, value),
      amount_preview("price", :nominal_amount, value),
      amount_preview("american", :nominal_amount, value),
      amount_preview("bullet", :nominal_amount, value)
    ]

    received = StarkInfra.CreditPreview.create!(sent)
    assert length(received) == length(sent)

    Enum.zip(sent, received)
    |> Enum.each(fn {%{credit: sent_note}, %{credit: received_note}} ->
      assert received_note.type == sent_note.type
      assert_amounts(sent_note, received_note, value)
    end)
  end

  defp assert_amounts(%{amount: nil}, received_note, value) do
    assert received_note.nominal_amount == value
    assert received_note.amount > 0
  end

  defp assert_amounts(_sent_note, received_note, value) do
    assert received_note.amount == value
    assert received_note.nominal_amount > 0
  end

  defp amount_preview(type, field, value) do
    %StarkInfra.CreditPreview{
      type: "credit-note",
      credit: struct(
        %StarkInfra.CreditPreview.CreditNotePreview{
          type: type,
          scheduled: Date.utc_today |> Date.add(Enum.random(11..19)) |> Date.to_string,
          tax_id: "012.345.678-90",
          initial_due: Date.utc_today |> Date.add(Enum.random(30..39)) |> Date.to_string,
          nominal_interest: 12.5
        },
        Map.merge(%{field => value}, installment_fields(type))
      )
    }
  end

  # bullet has a single installment, and the API rejects an interval for it
  defp installment_fields("bullet"), do: %{}
  defp installment_fields(_type), do: %{count: 12, interval: "month"}

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
