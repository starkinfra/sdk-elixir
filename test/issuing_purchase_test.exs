defmodule StarkInfraTest.IssuingPurchase do
  use ExUnit.Case

  @tag :issuing_purchase
  test "query issuing purchase test" do
    issuing_purchases = StarkInfra.IssuingPurchase.query(limit: 10)
      |> Enum.take(10)

    Enum.each(issuing_purchases, fn purchase ->
      {:ok, purchase} = purchase
      assert purchase.id == StarkInfra.IssuingPurchase.get!(purchase.id).id
    end)

    assert length(issuing_purchases) <= 10
  end

  @tag :issuing_purchase
  test "query! issuing purchase test" do
    issuing_purchases = StarkInfra.IssuingPurchase.query!(limit: 10)
      |> Enum.take(10)

    Enum.each(issuing_purchases, fn purchase ->
      assert purchase.id == StarkInfra.IssuingPurchase.get!(purchase.id).id
    end)

    assert length(issuing_purchases) <= 10
  end

  @tag :issuing_purchase
  test "page issuing purchase test" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingPurchase.page/1, 2, limit: 5)
    assert length(ids) <= 10

    Enum.each(ids, fn id ->
      {:ok, purchase} = StarkInfra.IssuingPurchase.get(id)
      assert purchase.id == id
    end)

  end

  @tag :issuing_purchase
  test "page! issuing purchase test" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingPurchase.page!/1, 2, limit: 5)
    assert length(ids) <= 10

    Enum.each(ids, fn id ->
      assert id == StarkInfra.IssuingPurchase.get!(id).id
    end)
  end

  @tag :issuing_purchase
  test "update issuing purchase test" do
    purchases = StarkInfra.IssuingPurchase.query!(limit: 1) |> Enum.take(1)
    assert purchases != [], "no IssuingPurchase in sandbox"
    purchase = purchases |> hd

    {:ok, updated_purchase} = StarkInfra.IssuingPurchase.update(purchase.id, description: "Dinner")

    assert updated_purchase.description == "Dinner"
  end

  @tag :issuing_purchase
  test "update! issuing purchase test" do
    purchases = StarkInfra.IssuingPurchase.query!(limit: 1) |> Enum.take(1)
    assert purchases != [], "no IssuingPurchase in sandbox"
    purchase = purchases |> hd

    updated_purchase = StarkInfra.IssuingPurchase.update!(purchase.id, description: "Dinner")

    assert updated_purchase.description == "Dinner"
  end

  @content "{\"acquirerId\": \"236090\", \"amount\": 100, \"cardId\": \"5671893688385536\", \"cardTags\": [], \"endToEndId\": \"2fa7ef9f-b889-4bae-ac02-16749c04a3b6\", \"holderId\": \"5917814565109760\", \"holderTags\": [], \"isPartialAllowed\": false, \"issuerAmount\": 100, \"issuerCurrencyCode\": \"BRL\", \"merchantAmount\": 100, \"merchantCategoryCode\": \"bookStores\", \"merchantCountryCode\": \"BRA\", \"merchantCurrencyCode\": \"BRL\", \"merchantFee\": 0, \"merchantId\": \"204933612653639\", \"merchantName\": \"COMPANY 123\", \"methodCode\": \"token\", \"purpose\": \"purchase\", \"score\": null, \"tax\": 0, \"walletId\": \"\"}"
  @signature "MEUCIBxymWEpit50lDqFKFHYOgyyqvE5kiHERi0ZM6cJpcvmAiEA2wwIkxcsuexh9BjcyAbZxprpRUyjcZJ2vBAjdd7o28Q="
  @bad_signature "MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk="
  @malformed_signature "something is definitely wrong"

  @tag :issuing_purchase
  test "response issuing purchase test" do
    response = StarkInfra.IssuingPurchase.response!("denied")
    assert !is_nil(response)
  end

  @tag :issuing_purchase
  test "parse issuing purchase test" do
    {:ok, {_purchase, cache_pid_1}} = StarkInfra.IssuingPurchase.parse(
      content: @content,
      signature: @signature
    )

    {:ok, {purchase, cache_pid_2}} =
      StarkInfra.IssuingPurchase.parse(
        content: @content,
        signature: @signature,
        cache_pid: cache_pid_1
      )

    assert Agent.get(cache_pid_1, fn map -> Map.get(map, :StarkInfra_public_key) end) ==
      Agent.get(cache_pid_2, fn map -> Map.get(map, :StarkInfra_public_key) end)

    assert !is_nil(purchase)
  end

  @tag :issuing_purchase
  test "parse bad signature issuing purchase test" do
    {:error, [error]} =
      StarkInfra.IssuingPurchase.parse(
        content: @content,
        signature: @bad_signature
      )
    assert error.code == "invalidSignature"
  end

  @tag :issuing_purchase
  test "parse invalid signature issuing purchase test" do
    {:error, [error]} =
      StarkInfra.IssuingPurchase.parse(
        content: @content,
        signature: @malformed_signature
      )

    assert error.code == "invalidSignature"
  end

  @tag :issuing_purchase
  test "parse! issuing purchase test" do
    {purchase, _cache_pid} = StarkInfra.IssuingPurchase.parse!(
      content: @content,
      signature: @signature
    )

    assert !is_nil(purchase)
  end

  @tag :issuing_purchase
  test "parse! bad signature issuing purchase test" do
    [error] = StarkInfra.IssuingPurchase.parse!(
      content: @content,
      signature: @bad_signature
    )

    assert error.code == "invalidSignature"
  end

  @tag :issuing_purchase
  test "parse! invalid signature issuing purchase test" do
    [error] = StarkInfra.IssuingPurchase.parse!(
      content: @content,
      signature: @malformed_signature
    )

    assert error.code == "invalidSignature"
  end
end
