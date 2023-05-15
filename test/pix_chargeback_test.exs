defmodule StarkInfraTest.PixChargeback do
  use ExUnit.Case

  @tag :pix_chargeback
  test "create pix chargeback" do
    {:ok, pix_chargebacks} = StarkInfra.PixChargeback.create([generate_example_pix_chargeback()])
    pix_chargeback = pix_chargebacks |> hd
    assert !is_nil(pix_chargeback.id)
  end

  @tag :pix_chargeback
  test "create! pix chargeback" do
    pix_chargeback = StarkInfra.PixChargeback.create!([generate_example_pix_chargeback()]) |> hd
    assert !is_nil(pix_chargeback.id)
  end

  @tag :pix_chargeback
  test "get pix chargeback" do
    pix_chargeback =
      StarkInfra.PixChargeback.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, chargeback} = StarkInfra.PixChargeback.get(pix_chargeback.id)

    assert !is_nil(chargeback.id)
  end

  @tag :pix_chargeback
  test "get! pix chargeback" do
    pix_chargeback =
      StarkInfra.PixChargeback.query!(limit: 1)
      |> Enum.take(1)
      |> hd()
    chargeback = StarkInfra.PixChargeback.get!(pix_chargeback.id)

    assert !is_nil(chargeback.id)
  end

  @tag :pix_chargeback
  test "query pix chargeback" do
    StarkInfra.PixChargeback.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_chargeback
  test "query! pix chargeback" do
    StarkInfra.PixChargeback.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_chargeback
  test "page pix chargeback" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixChargeback.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_chargeback
  test "page! pix chargeback" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixChargeback.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_chargeback
  test "update pix chargeback" do
    pix_chargeback =
      StarkInfra.PixChargeback.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, chargeback} = StarkInfra.PixChargeback.update(
      pix_chargeback.id,
      "rejected",
      rejection_reason: Enum.take_random(["noBalance", "accountClosed", "unableToReverse"], 1) |> hd(),
      reversal_reference_id: StarkInfra.Utils.ReturnId.create("35547753")
    )

    assert chargeback.status == "rejected"
  end

  @tag :pix_chargeback
  test "update! pix chargeback" do
    pix_chargeback =
      StarkInfra.PixChargeback.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    chargeback = StarkInfra.PixChargeback.update!(
      pix_chargeback.id,
      "rejected",
      rejection_reason: Enum.take_random(["noBalance", "accountClosed", "unableToReverse"], 1) |> hd(),
      reversal_reference_id: StarkInfra.Utils.ReturnId.create("35547753")
    )

    assert chargeback.status == "rejected"
  end

  @tag :pix_chargeback
  test "cancel pix chargeback" do
    pix_chargeback =
      StarkInfra.PixChargeback.query!(limit: 1, status: "delivered")
      |> Enum.take(1)
      |> hd()

    {:ok, chargeback} = StarkInfra.PixChargeback.cancel(pix_chargeback.id)

    assert chargeback.status == "canceled"
  end

  @tag :pix_chargeback
  test "cancel! pix chargeback" do
    pix_chargeback =
      StarkInfra.PixChargeback.query!(limit: 1, status: "delivered")
      |> Enum.take(1)
      |> hd()

    chargeback = StarkInfra.PixChargeback.cancel!(pix_chargeback.id)

    assert chargeback.status == "canceled"
  end
end
