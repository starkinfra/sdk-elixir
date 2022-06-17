defmodule StarkInfraTest.IssuingCard do
  use ExUnit.Case

  @tag :issuing_card
  test "query issuing card test" do
    {:ok, issuing_card} = StarkInfra.IssuingCard.query(limit: 10)
      |> Enum.take(1)
      |> hd

    assert !is_nil(issuing_card.id)
  end

  @tag :issuing_card
  test "query! issuing card test" do
    issuing_card = StarkInfra.IssuingCard.query!(limit: 10)
      |> Enum.take(1)
      |> hd

    assert !is_nil(issuing_card.id)
  end

  @tag :issuing_card
  test "page issuing card test" do
    {:ok, {_cursor, issuing_cards}} = StarkInfra.IssuingCard.page(limit: 10)
    issuing_card = issuing_cards |> Enum.take(1) |> hd

    assert !is_nil(issuing_card.id)
  end

  @tag :issuing_card
  test "page! issuing card test" do
    {_cursor, issuing_cards} = StarkInfra.IssuingCard.page!(limit: 10)
    issuing_card = issuing_cards |> Enum.take(1) |> hd

    assert !is_nil(issuing_card.id)
  end

  @tag :issuing_card
  test "create issuing card test" do
    {:ok, issuing_card} = StarkInfra.IssuingCard.create(
      [example_issuing_card()],
      expand: ["rules", "securityCode", "number", "expiration"]
    )
    issuing_card = issuing_card |> Enum.take(1) |> hd

    {:ok, card} = StarkInfra.IssuingCard.get(issuing_card.id)

    assert !is_nil(card.id)
  end

  @tag :issuing_card
  test "create! issuing card test" do
    issuing_card = StarkInfra.IssuingCard.create!(
      [example_issuing_card()],
      expand: ["rules", "securityCode", "number", "expiration"]
    )
    issuing_card = issuing_card |> Enum.take(1) |> hd

    {:ok, card} = StarkInfra.IssuingCard.get(issuing_card.id)

    assert !is_nil(card.id)
  end

  @tag :issuing_card
  test "update issuing card test" do
    issuing_card = StarkInfra.IssuingCard.create!([example_issuing_card()])
    issuing_card = issuing_card |> Enum.take(1) |> hd

    parameters = %{status: "blocked"}
    {:ok, card} = StarkInfra.IssuingCard.update(issuing_card.id, parameters)

    assert card.status == "blocked"
  end

  @tag :issuing_card
  test "update! issuing card test" do
    issuing_card = StarkInfra.IssuingCard.create!([example_issuing_card()])
    issuing_card = issuing_card |> Enum.take(1) |> hd

    parameters = %{status: "blocked"}
    card = StarkInfra.IssuingCard.update!(issuing_card.id, parameters)

    assert card.status == "blocked"
  end

  @tag :issuing_card
  test "cancel issuing card test" do
    issuing_card = StarkInfra.IssuingCard.create!([example_issuing_card()])
    issuing_card = issuing_card |> Enum.take(1) |> hd

    {:ok, deleted_issuing_card} = StarkInfra.IssuingCard.cancel(issuing_card.id)
    assert deleted_issuing_card.status == "canceled"
  end

  @tag :issuing_card
  test "cancel! issuing card test" do
    issuing_card = StarkInfra.IssuingCard.create!([example_issuing_card()])
    issuing_card = issuing_card |> Enum.take(1) |> hd

    deleted_issuing_card = StarkInfra.IssuingCard.cancel!(issuing_card.id)
    assert deleted_issuing_card.status == "canceled"
  end

  def example_issuing_card do
    StarkInfra.IssuingHolder.query!(limit: 10)
      |> Enum.take(1)
      |> hd
      |> build_example
  end

  def build_example(holder) do
    %StarkInfra.IssuingCard{
      city: "Sao Paulo",
      display_name: "ANTHONY STARK",
      district: "Bela Vista",
      holder_external_id: holder.external_id,
      holder_name: holder.name,
      holder_tax_id: holder.tax_id,
      rules: [
        %StarkInfra.IssuingRule{
          amount: 900000,
          currency_code: "BRL",
          interval: "week",
          name: "Example Rule"
        }
      ],
      state_code: "SP",
      street_line_1: "Av. Paulista, 200",
      street_line_2: "Apto. 123",
      tags: ["travel", "food"],
      zip_code: "01311-200"
    }
  end
end
