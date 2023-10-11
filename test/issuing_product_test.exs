defmodule StarkInfraTest.IssuingProduct do
  use ExUnit.Case

  @tag :issuing_product
  test "query issuing product" do
    {:ok, issuing_product} = StarkInfra.IssuingProduct.query(limit: 10)
      |> Enum.take(1)
      |> hd

    assert !is_nil(issuing_product.id)
  end

  @tag :issuing_product
  test "query! issuing product" do
    issuing_product = StarkInfra.IssuingProduct.query!(limit: 10)
      |> Enum.take(1)
      |> hd

    assert !is_nil(issuing_product.id)
  end

  @tag :issuing_product
  test "page issuing product" do
    {:ok, {_cursor, issuings_product}} = StarkInfra.IssuingProduct.page(limit: 10)
    issuing_product = issuings_product |> Enum.take(1) |> hd

    assert !is_nil(issuing_product.id)
  end

  @tag :issuing_product
  test "page! issuing product" do
    {nil, issuings_product} = StarkInfra.IssuingProduct.page!(limit: 10)
    issuing_product = issuings_product |> Enum.take(1) |> hd

    assert !is_nil(issuing_product.id)
  end
end
