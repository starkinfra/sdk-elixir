defmodule StarkInfraTest.PixDispute do
  use ExUnit.Case

  @tag :pix_dispute
  test "create pix dispute" do
    {:ok, pix_disputes} = StarkInfra.PixDispute.create([StarkInfraTest.Utils.PixDispute.generate_example_pix_dispute()])
    pix_dispute = pix_disputes |> hd
    assert !is_nil(pix_dispute.id)
  end

  @tag :pix_dispute
  test "create! pix dispute" do
    pix_dispute = StarkInfra.PixDispute.create!([StarkInfraTest.Utils.PixDispute.generate_example_pix_dispute()]) |> hd
    assert !is_nil(pix_dispute.id)
  end

  @tag :pix_dispute
  test "get pix dispute" do
    pix_dispute =
      StarkInfra.PixDispute.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, dispute} = StarkInfra.PixDispute.get(pix_dispute.id)

    assert !is_nil(dispute.id)
  end

  @tag :pix_dispute
  test "get! pix dispute" do
    pix_dispute =
      StarkInfra.PixDispute.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    dispute = StarkInfra.PixDispute.get!(pix_dispute.id)

    assert !is_nil(dispute.id)
  end

  @tag :pix_dispute
  test "query pix dispute" do
    StarkInfra.PixDispute.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_dispute
  test "query! pix dispute" do
    StarkInfra.PixDispute.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_dispute
  test "page pix dispute" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixDispute.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_dispute
  test "page! pix dispute" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixDispute.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_dispute
  test "cancel pix dispute" do
    disputes = StarkInfra.PixDispute.query!(limit: 1, status: "delivered") |> Enum.take(1)
    assert disputes != [], "no delivered PixDispute available in the sandbox to cancel"
    pix_dispute = hd(disputes)

    {:ok, dispute} = StarkInfra.PixDispute.cancel(pix_dispute.id)

    assert dispute.status == "canceled"
  end

  @tag :pix_dispute
  test "cancel! pix dispute" do
    disputes = StarkInfra.PixDispute.query!(limit: 1, status: "delivered") |> Enum.take(1)
    assert disputes != [], "no delivered PixDispute available in the sandbox to cancel"
    pix_dispute = hd(disputes)

    dispute = StarkInfra.PixDispute.cancel!(pix_dispute.id)

    assert dispute.status == "canceled"
  end
end
