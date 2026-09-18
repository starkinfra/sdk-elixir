defmodule StarkInfraTest.MerchantCountry do
  use ExUnit.Case

  @tag :merchant_country
  test "query merchant country" do
    StarkInfra.MerchantCountry.query()
      |> Enum.take(5)
      |> (fn countries -> assert length(countries) <= 5 end).()
  end

  @tag :merchant_country
  test "query! merchant country" do
    StarkInfra.MerchantCountry.query!()
      |> Enum.take(5)
      |> (fn countries -> assert length(countries) <= 5 end).()
  end

  @tag :merchant_country
  test "query merchant country with search" do
    countries = StarkInfra.MerchantCountry.query!(search: "brazil") |> Enum.take(10)
    assert countries != [], "no MerchantCountry found for search brazil"
  end

  @tag :merchant_country
  test "query! merchant country with search" do
    countries = StarkInfra.MerchantCountry.query!(search: "brazil") |> Enum.take(10)
    assert countries != [], "no MerchantCountry found for search brazil"
  end
end
