defmodule StarkInfraTest.MerchantCategory do
  use ExUnit.Case

  @tag :merchant_category
  test "query merchant category" do
    StarkInfra.MerchantCategory.query()
      |> Enum.take(5)
      |> (fn categories -> assert length(categories) <= 5 end).()
  end

  @tag :merchant_category
  test "query! merchant category" do
    StarkInfra.MerchantCategory.query!()
      |> Enum.take(5)
      |> (fn categories -> assert length(categories) <= 5 end).()
  end

  @tag :merchant_category
  test "query merchant category with search" do
    categories = StarkInfra.MerchantCategory.query!(search: "food") |> Enum.take(10)
    assert categories != [], "no MerchantCategory found for search food"
  end

  @tag :merchant_category
  test "query! merchant category with search" do
    categories = StarkInfra.MerchantCategory.query!(search: "food") |> Enum.take(10)
    assert categories != [], "no MerchantCategory found for search food"
  end
end
