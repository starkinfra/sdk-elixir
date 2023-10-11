defmodule StarkInfraTest.CardMethod do
  use ExUnit.Case

  @tag :card_method
  test "query card method test" do
    {:ok, methods} = StarkInfra.CardMethod.query(search: "token")
      |> Enum.take(1)
      |> hd

    assert !is_nil(methods.code)
  end

  @tag :card_method
  test "query! card method test" do
    methods = StarkInfra.CardMethod.query!(search: "token")
      |> Enum.take(1)
      |> hd

    assert !is_nil(methods.code)
  end
end
