defmodule StarkInfraTest.IssuingStockRule do
  use ExUnit.Case

  @tag :issuing_stock_rule
  test "create, update and cancel issuing stock rule" do
    stocks = StarkInfra.IssuingStock.query!(limit: 1) |> Enum.take(1)
    assert stocks != [], "no IssuingStock in sandbox"
    stock = stocks |> hd

    rule =
      StarkInfra.IssuingStockRule.create!([
        %StarkInfra.IssuingStockRule{
          minimum_balance: 1000,
          stock_id: stock.id,
          emails: ["john.doe@enterprise.com"]
        }
      ])
      |> hd

    assert !is_nil(rule.id)
    assert rule.stock_id == stock.id

    {:ok, updated_rule} = StarkInfra.IssuingStockRule.update(rule.id, minimum_balance: 10)
    assert updated_rule.id == rule.id

    {:ok, canceled_rule} = StarkInfra.IssuingStockRule.cancel(rule.id)
    assert canceled_rule.id == rule.id
  end

  @tag :issuing_stock_rule
  test "create!, update! and cancel! issuing stock rule" do
    stocks = StarkInfra.IssuingStock.query!(limit: 1) |> Enum.take(1)
    assert stocks != [], "no IssuingStock in sandbox"
    stock = stocks |> hd

    rule =
      StarkInfra.IssuingStockRule.create!([
        %StarkInfra.IssuingStockRule{
          minimum_balance: 1000,
          stock_id: stock.id,
          emails: ["john.doe@enterprise.com"]
        }
      ])
      |> hd

    assert !is_nil(rule.id)

    updated_rule = StarkInfra.IssuingStockRule.update!(rule.id, minimum_balance: 10)
    assert updated_rule.id == rule.id

    canceled_rule = StarkInfra.IssuingStockRule.cancel!(rule.id)
    assert canceled_rule.id == rule.id
  end

  @tag :issuing_stock_rule
  test "query issuing stock rule" do
    StarkInfra.IssuingStockRule.query(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_stock_rule
  test "query! issuing stock rule" do
    StarkInfra.IssuingStockRule.query!(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_stock_rule
  test "page issuing stock rule" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingStockRule.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_stock_rule
  test "page! issuing stock rule" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingStockRule.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
