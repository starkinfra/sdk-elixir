defmodule StarkInfraTest.CreditNote do
  use ExUnit.Case

  @tag :credit_note
  test "create credit note" do
    {:ok, credit_notes} = StarkInfra.CreditNote.create([example_credit_note()])
    credit_note = credit_notes |> hd
    assert !is_nil(credit_note.id)
  end

  @tag :credit_note
  test "create! credit note" do
    credit_note = StarkInfra.CreditNote.create!([example_credit_note()]) |> hd
    assert !is_nil(credit_note.id)
  end

  @tag :credit_note
  test "get credit note" do
    credit_note =
      StarkInfra.CreditNote.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, note} = StarkInfra.CreditNote.get(credit_note.id)

    assert !is_nil(note.id)
  end

  @tag :credit_note
  test "get! credit note" do
    credit_note =
      StarkInfra.CreditNote.query!(limit: 1)
      |> Enum.take(1)
      |> hd()
    note = StarkInfra.CreditNote.get!(credit_note.id)

    assert !is_nil(note.id)
  end

  @tag :credit_note
  test "query credit note" do
    StarkInfra.CreditNote.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :credit_note
  test "query! credit note" do
    StarkInfra.CreditNote.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :credit_note
  test "page credit note" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.CreditNote.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :credit_note
  test "page! credit note" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.CreditNote.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :credit_note
  test "create and cancel credit note" do
    credit_note = StarkInfra.CreditNote.create!([example_credit_note()]) |> hd

    assert !is_nil(credit_note)

    {:ok, note} = StarkInfra.CreditNote.cancel(credit_note.id)
    assert !is_nil(note.id)
  end

  @tag :credit_note
  test "create and cancel! credit note" do
    credit_note = StarkInfra.CreditNote.create!([example_credit_note()]) |> hd

    assert !is_nil(credit_note)

    note = StarkInfra.CreditNote.cancel!(credit_note.id)
    assert !is_nil(note.id)
  end

  def example_credit_note() do
    %StarkInfra.CreditNote{
      template_id: "5707012469948416",
      external_id: StarkInfraTest.Utils.Random.random_string(32),
      street_line_1: "Av. Paulista, 200",
      street_line_2: "10 andar",
      district: "Bela Vista",
      city: "Sao Paulo",
      state_code: "SP",
      zip_code: "01310-000",
      name: "Jamie Lannister",
      tax_id: "012.345.678-90",
      nominal_amount: 100000,
      scheduled: "2022-05-30",
      invoices: [
        %StarkInfra.CreditNote.Invoice{
          due: "2023-06-25",
          amount: 60000,
          fine: 10,
          interest: 2
        },
        %StarkInfra.CreditNote.Invoice{
          due: "2023-06-25",
          amount: 59000,
          fine: 10,
          interest: 1,
          descriptions: [
            %StarkInfra.CreditNote.Invoice.Description{
              key: "key",
              value: "value"
            }
          ]
        }
      ],
      tags: ["test", "testing"],
      payment: %{
        bank_code: "00000000",
        branch_code: "1234",
        account_number: "129340-1",
        name: "Jamie Lannister",
        tax_id: "012.345.678-90"
      },
      payment_type: "transfer",
      signers: [
        %{
          name: "Jamie Lannister",
          contact: "jamie.lannister@gmail.com",
          method: "link"
        }
      ],
    }
  end
end
