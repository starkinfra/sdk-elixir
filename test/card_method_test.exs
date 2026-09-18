defmodule StarkInfraTest.CardMethod do
  use ExUnit.Case

  @tag :card_method
  test "query card method" do
    StarkInfra.CardMethod.query()
      |> Enum.take(5)
      |> (fn methods -> assert length(methods) <= 5 end).()
  end

  @tag :card_method
  test "query! card method" do
    StarkInfra.CardMethod.query!()
      |> Enum.take(5)
      |> (fn methods -> assert length(methods) <= 5 end).()
  end

  @tag :card_method
  test "query card method with search" do
    methods = StarkInfra.CardMethod.query!(search: "token") |> Enum.take(10)
    assert methods != [], "no CardMethod found for search token"
  end

  @tag :card_method
  test "query! card method with search" do
    methods = StarkInfra.CardMethod.query!(search: "token") |> Enum.take(10)
    assert methods != [], "no CardMethod found for search token"
  end
end
