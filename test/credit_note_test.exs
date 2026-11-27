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

  @tag :credit_note
  test "get credit note pdf" do
    credit_note =
      StarkInfra.CreditNote.query!(limit: 1, status: "signed")
      |> Enum.take(1)
      |> hd()

    {:ok, pdf} = StarkInfra.CreditNote.pdf(credit_note.id)

    file = File.open!("./credit_note.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)

    assert byte_size(pdf) > 0
  end

  @tag :credit_note
  test "get! credit note pdf" do
    credit_note =
      StarkInfra.CreditNote.query!(limit: 1, status: "signed")
      |> Enum.take(1)
      |> hd()

    pdf = StarkInfra.CreditNote.pdf!(credit_note.id)

    file = File.open!("./credit_note1.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)

    assert byte_size(pdf) > 0
  end

  @tag :credit_note
  test "get credit note payment pdf" do
    credit_note =
      StarkInfra.CreditNote.query!(limit: 1, status: "success")
      |> Enum.take(1)
      |> hd()

    {:ok, payment} = StarkInfra.CreditNote.payment(credit_note.id)

    file = File.open!("./credit_note_payment.pdf", [:write])
    IO.binwrite(file, payment)
    File.close(file)

    assert byte_size(payment) > 0
  end

  @tag :credit_note
  test "get! credit note payment pdf" do
    credit_note =
      StarkInfra.CreditNote.query!(limit: 1, status: "success")
      |> Enum.take(1)
      |> hd()

    payment = StarkInfra.CreditNote.payment!(credit_note.id)

    file = File.open!("./credit_note_payment1.pdf", [:write])
    IO.binwrite(file, payment)
    File.close(file)

    assert byte_size(payment) > 0
  end

  @tag :credit_note
  test "create credit note returns signers as CreditSigner" do
    credit_note = StarkInfra.CreditNote.create!([example_credit_note()]) |> hd

    assert credit_note.signers != []
    assert Enum.all?(credit_note.signers, &match?(%StarkInfra.CreditSigner{}, &1))
  end

  @tag :credit_note
  test "create credit note with only amount" do
    # struct!/2 checks @enforce_keys at runtime, so this fails if nominal_amount is still required
    fields =
      example_credit_note()
      |> Map.from_struct()
      |> Map.delete(:nominal_amount)
      |> Map.put(:amount, 100000)

    credit_note = StarkInfra.CreditNote.create!([struct!(StarkInfra.CreditNote, fields)]) |> hd

    assert credit_note.amount == 100000
    assert credit_note.nominal_amount > 0
  end

  @tag :credit_note
  test "create credit note with template replacements" do
    # Runs against the sandbox with the rest of the suite: SANDBOX_TEMPLATE_ID must be a template with the nomeAvalista, taxIdAvalista and enderecoAvalista placeholders
    credit_note =
      struct!(
        example_credit_note(),
        template_replacements: %{
          nome_avalista: "Jon Snow",
          tax_id_avalista: "012.345.678-90",
          endereco_avalista: "Av. Paulista, 200 - Bela Vista - Sao Paulo, SP"
        },
        tags: ["sdk-test"]
      )

    created = StarkInfra.CreditNote.create!([credit_note]) |> hd

    assert created.template_replacements["nomeAvalista"] == "Jon Snow"
  end

  def example_credit_note() do
    today = Date.utc_today()

    %StarkInfra.CreditNote{
      template_id: existing_template_id(),
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
      scheduled: Date.add(today, 1),
      invoices: [
        %StarkInfra.CreditNote.Invoice{
          due: Date.add(today, 30),
          amount: 60000,
          fine: 10,
          interest: 2
        },
        %StarkInfra.CreditNote.Invoice{
          due: Date.add(today, 60),
          amount: 59000,
          fine: 10,
          interest: 2,
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
          contact: "jamie.lannister@invaliddomain.com",
          method: "link"
        }
      ],
    }
  end

  # Templates are enabled per workspace: SANDBOX_TEMPLATE_ID wins, otherwise reuse one an existing credit note already uses
  defp existing_template_id() do
    case System.get_env("SANDBOX_TEMPLATE_ID") do
      id when id in [nil, ""] ->
        StarkInfra.CreditNote.query!(limit: 1)
        |> Enum.take(1)
        |> hd()
        |> Map.fetch!(:template_id)

      id ->
        id
    end
  end
end
