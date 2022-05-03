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
            StarkInfra.CreditNote.query!()
            |> Enum.take(1)
            |> hd()

        {:ok, note} = StarkInfra.CreditNote.get(credit_note.id)

        assert !is_nil(note.id)
    end

    @tag :credit_note
    test "get! credit note" do
        credit_note =
            StarkInfra.CreditNote.query!()
            |> Enum.take(1)
            |> hd()
       note = StarkInfra.CreditNote.get!(credit_note.id)

        assert !is_nil(note.id)
    end

    @tag :credit_note
    test "query credit note" do
        credit_note =
            StarkInfra.CreditNote.query!(limit: 101, before: DateTime.utc_now())
            |> Enum.take(200)
            |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :credit_note
    test "query! credit note" do
        credit_note =
            StarkInfra.CreditNote.query!(limit: 101, before: DateTime.utc_now())
            |> Enum.take(200)
            |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :credit_note
    test "page credit note" do
        {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.CreditNote.page/1, 2, limit: 5)
        assert length(ids) == 10
    end

    @tag :credit_note
    test "page! credit note" do
        ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.CreditNote.page!/1, 2, limit: 5)
        assert length(ids) == 10
    end

    @tag :credit_note
    test "create and delete credit note" do
        credit_note = example_credit_note()
        credit_note = StarkInfra.CreditNote.create!([credit_note]) |> hd
        assert !is_nil(credit_note)
        note = StarkInfra.CreditNote.delete(credit_note.id)
        assert !is_nil(note.id)
    end

    @tag :credit_note
    test "create and delete! credit note" do
        credit_note = example_credit_note()
        credit_note = StarkInfra.CreditNote.create!([credit_note]) |> hd
        assert !is_nil(credit_note)
        note = StarkInfra.CreditNote.delete!(credit_note.id)
        assert !is_nil(note.id)
    end

    def example_credit_note() do
        %StarkInfra.CreditNote{
            template_id: "5686220801703936",
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
                    interest: 1
                }
            ],
            tags: ["test", "testing"],
            transfer: %StarkInfra.CreditNote.Transfer{
                bank_code: "00000000",
                branch_code: "1234",
                account_number: "129340-1",
                name: "Jamie Lannister",
                tax_id: "012.345.678-90"
            },
            signers: [
                %{
                    name: "Jamie Lannister",
                    contact: "jamie.lannister@gmail.com",
                    method: "link"
                }
            ],
        }
    end
    
    def get_future_datetime(days) do
        datetime = DateTime.utc_now
        DateTime.add(datetime, days*24*60*60, :second)
    end

end
