defmodule StarkInfraTest.CreditPreview do
  use ExUnit.Case

  @tag :credit_preview
  test "create credit previews" do
    {:ok, previews} = StarkInfra.CreditPreview.create(credit_notes())
    preview = previews |> hd()

    assert !is_nil(preview.type)
  end

  @tag :credit_preview
  test "create! credit previews" do
    previews = StarkInfra.CreditPreview.create!(credit_notes())
    preview = previews |> hd()

    assert !is_nil(preview.type)
  end

  @tag :credit_preview
  test "create credit previews in hash" do
    {:ok, previews} = StarkInfra.CreditPreview.create([credit_notes_hash()])
    preview = previews |> hd()

    assert !is_nil(preview.type)
  end

  @tag :credit_preview
  test "create! credit previews in hash" do
    previews = StarkInfra.CreditPreview.create!([credit_notes_hash()])
    preview = previews |> hd()

    assert !is_nil(preview.type)
  end

  defp credit_notes() do
  [
    %StarkInfra.CreditPreview{
      type: "credit-note",
      credit: %StarkInfra.CreditNotePreview{
        tax_id: "012.345.678-90",
        type: "sac",
        nominal_amount: 100000,
        rebate_amount: 1000,
        nominal_interest: 2.5,
        scheduled: "2023-11-28",
        initial_due: "2023-12-28",
        initial_amount: 9999,
        interval: "month"
      }
    },
    %StarkInfra.CreditPreview{
      type: "credit-note",
      credit: %StarkInfra.CreditNotePreview{
        tax_id: "012.345.678-90",
        type: "bullet",
        nominal_amount: 100000,
        rebate_amount: 1000,
        nominal_interest: 2.5,
        scheduled: "2023-11-28",
        initial_due: "2023-12-28",
      }
    },
    %StarkInfra.CreditPreview{
      type: "credit-note",
      credit: %StarkInfra.CreditNotePreview{
        tax_id: "012.345.678-90",
        type: "price",
        nominal_amount: 100000,
        rebate_amount: 1000,
        nominal_interest: 2.5,
        scheduled: "2023-11-28",
        initial_due: "2023-12-28",
        initial_amount: 9999,
        interval: "month"
      }
    },
    %StarkInfra.CreditPreview{
      type: "credit-note",
      credit: %StarkInfra.CreditNotePreview{
        tax_id: "012.345.678-90",
        type: "american",
        nominal_amount: 100000,
        rebate_amount: 1000,
        nominal_interest: 2.5,
        scheduled: "2023-11-28",
        initial_due: "2023-12-28",
        count: 12,
        interval: "year"
      }
    }
  ]
  end

  defp notes_hash() do
    %{
      tax_id: "012.345.678-90",
      type: "sac",
      nominal_amount: 100000,
      rebate_amount: 1000,
      nominal_interest: 3.0,
      scheduled: "2023-11-28",
      initial_due: "2023-12-28",
      initial_amount: 9999,
      interval: "year"
    }
  end

  defp credit_notes_hash() do
    %StarkInfra.CreditPreview{
      type: "credit-note",
      credit: notes_hash()
    }
  end
end
