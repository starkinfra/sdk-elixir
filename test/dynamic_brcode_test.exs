defmodule StarkInfraTest.DynamicBrcode do
  use ExUnit.Case

  @tag :dynamic_brcode
  test "get dynamic brcode" do
    brcodes = StarkInfra.DynamicBrcode.query!(limit: 1)
      |> Enum.take(1)
      |> hd

    {:ok, brcode} = StarkInfra.DynamicBrcode.get(brcodes.uuid)

    assert !is_nil(brcode.id)
  end

  @tag :dynamic_brcode
  test "get! dynamic brcode" do
    brcodes = StarkInfra.DynamicBrcode.query!(limit: 1)
      |> Enum.take(1)
      |> hd

    brcode = StarkInfra.DynamicBrcode.get!(brcodes.uuid)

    assert !is_nil(brcode.id)
  end

  @tag :dynamic_brcode
  test "query dynamic brcode" do
    {:ok, brcodes} = StarkInfra.DynamicBrcode.query(before: Date.utc_today |> Date.add(-1))
      |> Enum.take(1)
      |> hd

    assert !is_nil(brcodes.id)
  end

  @tag :dynamic_brcode
  test "query! dynamic brcode" do
    brcodes = StarkInfra.DynamicBrcode.query!(before: Date.utc_today |> Date.add(-1))
      |> Enum.take(1)
      |> hd

    assert !is_nil(brcodes.id)
  end

  @tag :dynamic_brcode
  test "page dynamic brcode test" do
    {:ok, {_cursor, brcodes}} = StarkInfra.DynamicBrcode.page(limit: 2)
    brcode = brcodes |> Enum.take(1) |> hd

    assert !is_nil(brcode.id)
  end

  @tag :dynamic_brcode
  test "page! dynamic brcode test" do
    {_cursor, brcodes} = StarkInfra.DynamicBrcode.page!(limit: 2)
    brcode = brcodes |> Enum.take(1) |> hd

    assert !is_nil(brcode.id)
  end

  @tag :dynamic_brcode
  test "create dynamic brcode test" do
    {:ok, brcode} = StarkInfra.DynamicBrcode.create(
      [example_dynamic_brcode()]
    )
    brcode = brcode |> Enum.take(1) |> hd

    assert !is_nil(brcode.id)
  end

  @tag :dynamic_brcode
  test "create! dynamic brcode test" do
    brcode = StarkInfra.DynamicBrcode.create!(
      [example_dynamic_brcode()]
    )
    brcode = brcode |> Enum.take(1) |> hd

    assert !is_nil(brcode.id)
  end

  @tag :dynamic_brcode
  test "response due dynamic brcode test" do
    response = StarkInfra.DynamicBrcode.response_due(
      example_dynamic_brcode_due()
    )

    assert !is_nil(response)
  end

  @tag :dynamic_brcode
  test "response instant dynamic brcode test" do
    response = StarkInfra.DynamicBrcode.response_instant(
      example_dynamic_brcode_instant()
    )

    assert !is_nil(response)
  end

  @tag :dynamic_brcode
  test "verify right dynamic brcode test" do
    uuid = "21f174ab942843eb90837a5c3135dfd6"
    right_signature = "MEYCIQC+Ks0M54DPLEbHIi0JrMiWbBFMRETe/U2vy3gTiid3rAIhANMmOaxT03nx2bsdo+vg6EMhWGzdphh90uBH9PY2gJdd"
    verified_response = StarkInfra.DynamicBrcode.verify!(content: uuid, signature: right_signature)
    verified_response = verified_response |> Enum.take(1) |> hd

    assert !is_nil(verified_response)
  end

  @tag :dynamic_brcode
  test "verify wrong dynamic brcode test" do
    uuid = "21f174ab942843eb90837a5c3135dfd6"
    wrong_signature = "MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk="
    verified_response = StarkInfra.DynamicBrcode.verify!(content: uuid, signature: wrong_signature)
    verified_response = verified_response |> Enum.take(1) |> hd

    assert !is_nil(verified_response)
  end

  def example_dynamic_brcode do
    StarkInfra.DynamicBrcode.query!(limit: 10)
      |> Enum.take(1)
      |> hd
      |> build_example
  end

  def build_example(brcode) do
    %StarkInfra.DynamicBrcode{
      name: "Jamie Lannister",
      city: "Rio de Janeiro",
      external_id: StarkInfraTest.Utils.Random.random_string(32),
      type: brcode.type
    }
  end

  def example_dynamic_brcode_instant() do
    %{
      version: 1,
      created: "2022-08-27T14:08:38.806507+00:00",
      key_id: "+5511989898989",
      status: "paid",
      reconciliation_id: "b77f5236-7ab9-4487-9f95-66ee6eaf1781",
      amount: 10000,
      cashier_type: "merchant",
      cashier_bank_code: "20018183",
      cash_amount: 20018183,
      expiration: 86400,
      sender_name: "Anthony Edward Stark",
      sender_tax_id: "01.001.001/0001-01",
      amount_type: "fixed",
      description: "Test Instant Response",
    }
  end

  def example_dynamic_brcode_due() do
    %{
      version: 1,
      created: "2022-08-27T14:08:38.806507+00:00",
      due: "2022-09-27T14:08:38.806507+00:00",
      expiration: 999,
      key_id: "+5511989898989",
      status: "paid",
      reconciliation_id: "b77f5236-7ab9-4487-9f95-66ee6eaf1781",
      nominal_amount: 100,
      sender_name: "Anthony Edward Stark",
      sender_tax_id: "012.345.678-90",
      receiver_name: "Jamie Lannister",
      receiver_street_line: "Av. Paulista, 200",
      receiver_city: "Sao Paulo",
      receiver_state_code: "SP",
      receiver_zip_code: "01234-567",
      receiver_tax_id: "20.018.183/0001-8",
      fine: 2,
      interest: 1,
      discounts: "",
      description: "Test Elixir"
    }
  end
end
