defmodule StarkInfraTest.IssuingCardWithoutHolder do
  use ExUnit.Case

  alias StarkInfra.IssuingCard
  alias StarkInfra.IssuingHolder
  alias StarkInfra.IssuingProduct
  alias StarkInfra.Utils.API

  # The :payload tests are offline: they check the JSON the SDK builds for the API (the HTTP call goes straight to :httpc and
  # has no seam to replace). The :sandbox tests run against the real API and cancel every card they create.

  @tag :issuing_card_payload
  test "an IssuingCard struct can be built without holder fields and they are not sent" do
    card = %IssuingCard{product_id: "123", type: "physical"}

    assert API.api_json(card) == %{"productId" => "123", "type" => "physical"}
  end

  @tag :issuing_card_payload
  test "holder fields are sent when informed" do
    card = %IssuingCard{
      holder_name: "Tony Stark",
      holder_tax_id: "012.345.678-90",
      holder_external_id: "my-entity/123",
      product_id: "123"
    }

    assert API.api_json(card) == %{
      "holderName" => "Tony Stark",
      "holderTaxId" => "012.345.678-90",
      "holderExternalId" => "my-entity/123",
      "productId" => "123"
    }
  end

  # Checks API.api_json on the maps update_multi receives (the request itself is covered by the sandbox tests below).
  @tag :issuing_card_payload
  test "api_json casts batch items keeping only informed fields" do
    items = [
      %{id: "1", holder_name: "Tony Stark", holder_tax_id: "012.345.678-90", holder_external_id: "my-entity/123"},
      %{id: "2", tags: ["batch"], holder_name: nil}
    ]

    assert Enum.map(items, &API.api_json/1) == [
      %{"id" => "1", "holderName" => "Tony Stark", "holderTaxId" => "012.345.678-90", "holderExternalId" => "my-entity/123"},
      %{"id" => "2", "tags" => ["batch"]}
    ]
  end

  # ---- sandbox ----

  defp first_product do
    IssuingProduct.query!(limit: 1) |> Enum.at(0) || flunk("the sandbox Project has no IssuingProduct")
  end

  # A holder can only be linked to a product of its own type: business holders have a CNPJ (14 digits) and individual holders
  # a CPF (11 digits). Existing holders are used so no personal data is created by the test.
  defp holder_for(product) do
    digits = %{"business" => 14, "individual" => 11}[product.holder_type] || raise "unknown holder_type #{inspect(product.holder_type)}"

    IssuingHolder.query!(status: "active", limit: 100)
    |> Enum.find(fn holder -> holder.tax_id |> String.replace(~r/\D/, "") |> String.length() == digits end)
  end

  defp cards_without_holder(n, type, product_id) do
    for _ <- 1..n, do: %IssuingCard{product_id: product_id, type: type, tags: ["sdk-test"]}
  end

  defp cancel_all(cards) do
    Enum.each(cards, fn card ->
      case IssuingCard.cancel(card.id) do
        {:ok, _} -> :ok
        {:error, _} -> IO.puts("could not cancel card #{card.id}")
      end
    end)
  end

  defp holder_fields(holder) do
    %{holder_name: holder.name, holder_tax_id: holder.tax_id, holder_external_id: holder.external_id}
  end

  defp rejected_codes({:error, errors}), do: Enum.map(errors, & &1.code)

  # Creates pending physical cards without holder, runs the test with them and always cancels them.
  defp with_pending_cards(n, test_function) do
    product = first_product()
    holder = holder_for(product)
    assert holder, "the sandbox needs an existing active holder compatible with the product"
    cards = IssuingCard.create!(cards_without_holder(n, "physical", product.id))

    try do
      test_function.(cards, holder)
    after
      cancel_all(cards)
    end
  end

  @tag :issuing_card_sandbox
  test "a physical card without holder is created pending" do
    cards = IssuingCard.create!(cards_without_holder(1, "physical", first_product().id))

    try do
      assert length(cards) == 1
      assert hd(cards).status == "pending"
      assert hd(cards).type == "physical"
      assert hd(cards).holder_id == ""
      assert hd(cards).holder_name == ""
    after
      cancel_all(cards)
    end
  end

  @tag :issuing_card_sandbox
  test "the API rejects a virtual card without holder" do
    assert "invalidHolder" in rejected_codes(IssuingCard.create(cards_without_holder(1, "virtual", first_product().id)))
  end

  @tag :issuing_card_sandbox
  test "the API rejects incomplete holder fields on create" do
    card = %IssuingCard{product_id: first_product().id, type: "physical", holder_name: "Tony Stark"}

    assert "invalidHolder" in rejected_codes(IssuingCard.create([card]))
  end

  @tag :issuing_card_sandbox
  test "the holder is assigned to a pending card" do
    with_pending_cards(1, fn [card], holder ->
      {:ok, updated} = IssuingCard.update(card.id, Map.to_list(holder_fields(holder)))

      assert updated.status == "pending"
      assert updated.holder_id == holder.id
    end)
  end

  @tag :issuing_card_sandbox
  test "the holder is assigned and the card activated in the same call" do
    with_pending_cards(1, fn [card], holder ->
      {:ok, updated} = IssuingCard.update(card.id, Map.to_list(holder_fields(holder)) ++ [status: "active", pin: "1234"])

      assert updated.status == "active"
      assert updated.holder_id == holder.id
    end)
  end

  @tag :issuing_card_sandbox
  test "the API rejects incomplete holder fields on update" do
    with_pending_cards(1, fn [card], holder ->
      assert "invalidHolder" in rejected_codes(IssuingCard.update(card.id, holder_name: holder.name))
    end)
  end

  @tag :issuing_card_sandbox
  test "the API rejects activation without holder" do
    with_pending_cards(1, fn [card], _holder ->
      assert "invalidHolder" in rejected_codes(IssuingCard.update(card.id, status: "active", pin: "1234"))
    end)
  end

  @tag :issuing_card_sandbox
  test "the holder is assigned to several cards" do
    with_pending_cards(2, fn cards, holder ->
      items = Enum.map(cards, fn card -> Map.put(holder_fields(holder), :id, card.id) end)

      {:ok, updated} = IssuingCard.update_multi(items)

      assert Enum.sort(Enum.map(updated, & &1.id)) == Enum.sort(Enum.map(cards, & &1.id))
      assert Enum.all?(updated, fn card -> card.holder_id == holder.id end)
    end)
  end

  @tag :issuing_card_sandbox
  test "the API rejects the whole list when one item is invalid" do
    with_pending_cards(2, fn [first, _second], holder ->
      items = [
        Map.put(holder_fields(holder), :id, first.id),
        Map.put(holder_fields(holder), :id, "0000000000000001")
      ]

      assert "invalidCard" in rejected_codes(IssuingCard.update_multi(items))
      assert IssuingCard.get!(first.id).holder_id == ""
    end)
  end

  @tag :issuing_card_sandbox
  test "the API rejects incomplete holder fields on update_multi" do
    with_pending_cards(1, fn [card], holder ->
      assert "invalidHolder" in rejected_codes(IssuingCard.update_multi([%{id: card.id, holder_name: holder.name}]))
    end)
  end

  @tag :issuing_card_sandbox
  test "the API rejects pin in the batch" do
    with_pending_cards(1, fn [card], _holder ->
      assert "invalidJson" in rejected_codes(IssuingCard.update_multi([%{id: card.id, pin: "1234"}]))
    end)
  end

  @tag :issuing_card_sandbox
  test "the API rejects display_name in the batch" do
    with_pending_cards(1, fn [card], _holder ->
      assert "invalidJson" in rejected_codes(IssuingCard.update_multi([%{id: card.id, display_name: "Name"}]))
    end)
  end

  @tag :issuing_card_sandbox
  test "update_multi! raises with the API error text" do
    error = assert_raise RuntimeError, fn -> IssuingCard.update_multi!([%{id: "0000000000000001", tags: ["sdk-test"]}]) end

    assert error.message =~ "invalidCard"
  end
end
