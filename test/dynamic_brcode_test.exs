defmodule StarkInfraTest.DynamicBrcode do
  use ExUnit.Case

  @tag :dynamic_brcode
  test "create dynamic brcode" do
    {:ok, brcodes} = StarkInfra.DynamicBrcode.create([StarkInfraTest.Utils.DynamicBrcode.generate_example_dynamic_brcode()])
    brcode = brcodes |> hd
    assert !is_nil(brcode.uuid)
  end

  @tag :dynamic_brcode
  test "create! dynamic brcode" do
    brcode = StarkInfra.DynamicBrcode.create!([StarkInfraTest.Utils.DynamicBrcode.generate_example_dynamic_brcode()]) |> hd
    assert !is_nil(brcode.uuid)
  end

  @tag :dynamic_brcode
  test "query dynamic brcode" do
    StarkInfra.DynamicBrcode.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :dynamic_brcode
  test "query! dynamic brcode" do
    StarkInfra.DynamicBrcode.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  # DynamicBrcode.id is the BR code payload text, not a unique key (two brcodes created
  # with the same parameters produce the same id): pages are deduplicated by uuid instead,
  # unlike StarkInfraTest.Utils.Page, which assumes entity.id is unique.
  @tag :dynamic_brcode
  test "page dynamic brcode" do
    uuids = collect_pages(
      fn options ->
        {:ok, page} = StarkInfra.DynamicBrcode.page(options)
        page
      end,
      2,
      limit: 5
    )
    assert length(uuids) <= 10
  end

  @tag :dynamic_brcode
  test "page! dynamic brcode" do
    uuids = collect_pages(&StarkInfra.DynamicBrcode.page!/1, 2, limit: 5)
    assert length(uuids) <= 10
  end

  defp collect_pages(page_fun, iterations, options) do
    collect_pages(page_fun, iterations, options, [])
  end

  defp collect_pages(_page_fun, 0, _options, uuids), do: uuids

  defp collect_pages(page_fun, iterations, options, uuids) do
    case page_fun.(options) do
      {_cursor, []} ->
        uuids

      {cursor, brcodes} ->
        new_uuids = Enum.map(brcodes, & &1.uuid)
        assert Enum.all?(new_uuids, fn uuid -> uuid not in uuids end)
        combined = uuids ++ new_uuids

        case cursor do
          nil -> combined
          _ -> collect_pages(page_fun, iterations - 1, Keyword.put(options, :cursor, cursor), combined)
        end
    end
  end

  @tag :dynamic_brcode
  test "get dynamic brcode" do
    brcode =
      StarkInfra.DynamicBrcode.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, fetched} = StarkInfra.DynamicBrcode.get(brcode.uuid)

    assert fetched.uuid == brcode.uuid
  end

  @tag :dynamic_brcode
  test "get! dynamic brcode" do
    brcode =
      StarkInfra.DynamicBrcode.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    fetched = StarkInfra.DynamicBrcode.get!(brcode.uuid)

    assert fetched.uuid == brcode.uuid
  end

  @tag :dynamic_brcode
  test "response due dynamic brcode" do
    response = StarkInfra.DynamicBrcode.response_due!(
      version: 1,
      created: DateTime.utc_now(),
      due: DateTime.utc_now() |> DateTime.add(3 * 24 * 60 * 60, :second),
      key_id: "+5511989898989",
      status: "paid",
      reconciliation_id: "cd65c78aeb6543eaaa0170f68bd741ee",
      nominal_amount: 100,
      sender_name: "Anthony Edward Stark",
      sender_tax_id: "012.345.678-90",
      receiver_name: "Jamie Lannister",
      receiver_tax_id: "012.345.678-90",
      receiver_street_line: "Av. Paulista, 200",
      receiver_city: "Sao Paulo",
      receiver_state_code: "SP",
      receiver_zip_code: "01234-567"
    )

    assert response =~ "nominalAmount"
    assert response =~ "keyId"
    assert response =~ "reconciliationId"
    assert response =~ "receiverStreetLine"
    assert response =~ "receiverStateCode"
    assert response =~ "receiverZipCode"
  end

  @tag :dynamic_brcode
  test "response instant dynamic brcode" do
    response = StarkInfra.DynamicBrcode.response_instant!(
      version: 1,
      created: DateTime.utc_now(),
      key_id: "+5511989898989",
      status: "paid",
      reconciliation_id: "cd65c78aeb6543eaaa0170f68bd741ee",
      amount: 100,
      cashier_type: "merchant",
      cashier_bank_code: "20018183",
      cash_amount: 0
    )

    assert response =~ "keyId"
    assert response =~ "reconciliationId"
    assert response =~ "cashierType"
    assert response =~ "cashierBankCode"
  end

  @tag :dynamic_brcode
  test "verify wrong signature dynamic brcode" do
    {:error, errors} = StarkInfra.DynamicBrcode.verify(
      uuid: "4e2eab725ddd495f9c98ffd97440702d",
      signature: "MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk="
    )

    Enum.each(errors, fn error ->
      assert error.code === "invalidSignature"
    end)
  end

  @tag :dynamic_brcode
  test "verify! wrong signature dynamic brcode raises" do
    assert_raise RuntimeError, fn ->
      StarkInfra.DynamicBrcode.verify!(
        uuid: "4e2eab725ddd495f9c98ffd97440702d",
        signature: "MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk="
      )
    end
  end

  @tag :dynamic_brcode
  test "verify malformed signature dynamic brcode" do
    {:error, errors} = StarkInfra.DynamicBrcode.verify(
      uuid: "4e2eab725ddd495f9c98ffd97440702d",
      signature: "not-a-valid-base64-signature"
    )

    Enum.each(errors, fn error ->
      assert error.code === "invalidSignature"
    end)
  end

  # NOTE: there is no fixture in this repo for a genuinely signed uuid (one actually
  # produced by the Stark Infra private key for a real DynamicBrcode read), so a
  # valid-signature verify test is intentionally omitted, mirroring the sibling
  # PixRequest.parse tests which only cover the wrong/malformed error paths plus one
  # hardcoded valid pair that we do not have an equivalent for here.
end
