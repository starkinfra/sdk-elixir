defmodule StarkInfraTest.PixFraud do
  use ExUnit.Case

  @tag :pix_fraud
  test "create pix fraud" do
    {:ok, pix_frauds} = StarkInfra.PixFraud.create([StarkInfraTest.Utils.PixFraud.generate_example_pix_fraud()])
    pix_fraud = pix_frauds |> hd
    assert !is_nil(pix_fraud.id)
  end

  @tag :pix_fraud
  test "create! pix fraud" do
    pix_fraud = StarkInfra.PixFraud.create!([StarkInfraTest.Utils.PixFraud.generate_example_pix_fraud()]) |> hd
    assert !is_nil(pix_fraud.id)
  end

  @tag :pix_fraud
  test "get pix fraud" do
    pix_fraud =
      StarkInfra.PixFraud.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, fraud} = StarkInfra.PixFraud.get(pix_fraud.id)

    assert !is_nil(fraud.id)
  end

  @tag :pix_fraud
  test "get! pix fraud" do
    pix_fraud =
      StarkInfra.PixFraud.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    fraud = StarkInfra.PixFraud.get!(pix_fraud.id)

    assert !is_nil(fraud.id)
  end

  @tag :pix_fraud
  test "query pix fraud" do
    StarkInfra.PixFraud.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_fraud
  test "query! pix fraud" do
    StarkInfra.PixFraud.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_fraud
  test "page pix fraud" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixFraud.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_fraud
  test "page! pix fraud" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixFraud.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_fraud
  test "cancel pix fraud" do
    [pix_fraud | _] =
      StarkInfra.PixFraud.query!(limit: 2, status: "registered")
      |> Enum.take(2)

    {:ok, fraud} = StarkInfra.PixFraud.cancel(pix_fraud.id)

    assert fraud.id == pix_fraud.id
  end

  @tag :pix_fraud
  test "cancel! pix fraud" do
    [_, pix_fraud] =
      StarkInfra.PixFraud.query!(limit: 2, status: "registered")
      |> Enum.take(2)

    fraud = StarkInfra.PixFraud.cancel!(pix_fraud.id)

    assert fraud.id == pix_fraud.id
  end
end
