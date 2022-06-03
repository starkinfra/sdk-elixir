defmodule StarkInfraTest.PixKey do
  use ExUnit.Case

  @tag :pix_key
  test "create pix key" do
    {:ok, pix_key} = StarkInfra.PixKey.create(example_pix_key())
    assert !is_nil(pix_key.id)
  end

  @tag :pix_key
  test "create! pix key" do
    pix_key = StarkInfra.PixKey.create!(example_pix_key())
    assert !is_nil(pix_key.id)
  end

  @tag :pix_key
  test "get pix key" do
    pix_key = StarkInfra.PixKey.query!(limit: 10, status: "registered")
      |> Enum.take(1)
      |> hd()

    assert !is_nil(pix_key.id)
    assert byte_size(pix_key.id) > 0

    {:ok, key} = StarkInfra.PixKey.get(pix_key.id, "012.345.678-90")

    assert !is_nil(key.id)
  end

  @tag :pix_key
  test "get! pix key" do
    pix_key = StarkInfra.PixKey.query!(limit: 10, status: "registered")
      |> Enum.take(1)
      |> hd()

    assert !is_nil(pix_key.id)
    assert byte_size(pix_key.id) > 0

    key = StarkInfra.PixKey.get!(pix_key.id, pix_key.tax_id)

    assert !is_nil(key.id)
  end

  @tag :pix_key
  test "query pix key" do
    StarkInfra.PixKey.query!(limit: 20, status: "registered")
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 20 end).()
  end

  @tag :pix_key
  test "query! pix key" do
    StarkInfra.PixKey.query!(limit: 20)
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 20 end).()
  end

  @tag :pix_key
  test "page pix key" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixKey.page/1, 2, limit: 5, status: "registered")
    assert length(ids) <= 10
  end

  @tag :pix_key
  test "page! pix key" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixKey.page!/1, 2, limit: 5, status: "registered")
    assert length(ids) <= 10
  end

  @tag :pix_key
  test "update pix key" do
    pix_key = StarkInfra.PixKey.query!(limit: 1, status: "registered")
      |> Enum.take(1)
      |> hd()

    assert !is_nil(pix_key.id)
    assert byte_size(pix_key.id) > 0

    {:ok, pix_key} = StarkInfra.PixKey.update(pix_key.id, "reconciliation", name: "starkinfra")
    assert !is_nil(pix_key.id)
    assert byte_size(pix_key.id) > 0
    assert pix_key.name == "starkinfra"
  end

  @tag :pix_key
  test "update! pix key" do
    pix_key = StarkInfra.PixKey.query!(limit: 1, status: "registered")
      |> Enum.take(1)
      |> hd()

    assert !is_nil(pix_key.id)
    assert byte_size(pix_key.id) > 0

    pix_key = StarkInfra.PixKey.update!(pix_key.id, "reconciliation", name: "starkinfra")
    assert !is_nil(pix_key.id)
    assert byte_size(pix_key.id) > 0
    assert pix_key.name == "starkinfra"
  end

  @tag :pix_key
  test "cancel pix key" do
    pix_key = StarkInfra.PixKey.query!(limit: 1, status: "registered")
      |> Enum.take(1)
      |> hd()

    assert !is_nil(pix_key.id)
    assert byte_size(pix_key.id) > 0

    {:ok, pix_key} = StarkInfra.PixKey.cancel(pix_key.id)
    assert !is_nil(pix_key.id)
    assert byte_size(pix_key.id) > 0
  end

  @tag :pix_key
  test "cancel! pix key" do
    pix_key = StarkInfra.PixKey.query!(limit: 1, status: "registered")
      |> Enum.take(1)
      |> hd()

    assert !is_nil(pix_key.id)
    assert byte_size(pix_key.id) > 0

    pix_key = StarkInfra.PixKey.cancel!(pix_key.id)
    assert !is_nil(pix_key.id)
    assert byte_size(pix_key.id) > 0
  end

  @tag :pix_key
  test "query pix and cancel" do
    StarkInfra.PixKey.query(limit: 20)
      |> Enum.take(10)
      |> Enum.each(fn {:ok, pix_key} -> StarkInfra.PixKey.cancel(pix_key.id) end)
  end

  def example_pix_key() do
    %StarkInfra.PixKey{
      account_created: "2022-02-01",
      account_number: "0000-1",
      account_type: "savings",
      branch_code: "0000-1",
      name: "testClaim",
      tax_id: "012.345.678-90"
    }
  end
end
