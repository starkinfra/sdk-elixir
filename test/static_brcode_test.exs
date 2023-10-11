defmodule StarkInfraTest.StaticBrcode do
  use ExUnit.Case

  @tag :static_brcode
  test "get dynamic brcode" do

    brcodes = StarkInfra.StaticBrcode.query!(limit: 1)
      |> Enum.take(1)
      |> hd

    {:ok, brcode} = StarkInfra.StaticBrcode.get(brcodes.uuid)

    assert !is_nil(brcode.id)
  end

  @tag :static_brcode
  test "get! dynamic brcode" do
    brcodes = StarkInfra.StaticBrcode.query!(limit: 1)
      |> Enum.take(1)
      |> hd

    brcode = StarkInfra.StaticBrcode.get!(brcodes.uuid)

    assert !is_nil(brcode.id)
  end

  @tag :static_brcode
  test "query static brcode test" do
    {:ok, brcodes} = StarkInfra.StaticBrcode.query(
      before: Date.utc_today |> Date.add(-1),
      limit: 8)
      |> Enum.take(1)
      |> hd

    assert !is_nil(brcodes.id)
  end

  @tag :static_brcode
  test "query! static brcode test" do
    brcodes = StarkInfra.StaticBrcode.query!(limit: 10)
      |> Enum.take(1)
      |> hd

    assert !is_nil(brcodes.id)
  end

  @tag :static_brcode
  test "page static brcode test" do
    {:ok, {_cursor, brcodes}} = StarkInfra.StaticBrcode.page(limit: 10)
    brcode = brcodes |> Enum.take(1) |> hd

    assert !is_nil(brcode.id)
  end

  @tag :static_brcode
  test "page! static brcode test" do
    {_cursor, brcodes} = StarkInfra.StaticBrcode.page!(limit: 10)
    brcode = brcodes |> Enum.take(1) |> hd

    assert !is_nil(brcode.id)
  end

  @tag :static_brcode
  test "create static brcode test" do
    {:ok, brcode} = StarkInfra.StaticBrcode.create(
      [example_static_brcode()]
    )

    brcode = brcode |> Enum.take(1) |> hd

    assert !is_nil(brcode.id)
  end

  @tag :static_brcode
  test "create! static brcode test" do
    brcode = StarkInfra.StaticBrcode.create!(
      [example_static_brcode()]
    )

    brcode = brcode |> Enum.take(1) |> hd

    assert !is_nil(brcode.id)
  end

  def example_static_brcode do
    StarkInfra.StaticBrcode.query!(limit: 10)
      |> Enum.take(1)
      |> hd
      |> build_example
  end

  def build_example(brcode) do
    %StarkInfra.StaticBrcode{
      name: "Jamie Lannister",
      key_id: "+5511988887777",
      amount: brcode.amount,
      reconciliation_id: "123",
      cashier_bank_code: "20018183",
      description: "A StaticBrcode",
      city: "São Paulo"
    }
  end
end
