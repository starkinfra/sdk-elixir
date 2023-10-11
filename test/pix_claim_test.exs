defmodule StarkInfraTest.PixClaim do
  use ExUnit.Case

  @tag :pix_claim
  test "create pix claim" do
    {:ok, pix_claim} = StarkInfra.PixClaim.create(example_pix_claim())
    assert !is_nil(pix_claim.id)
  end

  @tag :pix_claim
  test "create! pix claim" do
    pix_claim = StarkInfra.PixClaim.create!(example_pix_claim())
    assert !is_nil(pix_claim.id)
  end

  @tag :pix_claim
  test "get pix claim" do
    pix_claim = StarkInfra.PixClaim.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, claim} = StarkInfra.PixClaim.get(pix_claim.id)

    assert !is_nil(claim.id)
  end

  @tag :pix_claim
  test "get! pix claim" do
    pix_claim = StarkInfra.PixClaim.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    claim = StarkInfra.PixClaim.get!(pix_claim.id)

    assert !is_nil(claim.id)
  end

  @tag :pix_claim
  test "update pix claim" do
    pix_claim = StarkInfra.PixClaim.query!(limit: 1, status: "delivered", flow: "out")
      |> Enum.take(1)
      |> hd()

    {:ok, claim} = StarkInfra.PixClaim.update(pix_claim.id, "canceled", reason: "fraud")

    assert !is_nil(claim.id)
  end

  @tag :pix_claim
  test "update! pix claim" do
    pix_claim = StarkInfra.PixClaim.query!(limit: 1, status: "delivered", flow: "out")
      |> Enum.take(1)
      |> hd

    claim = StarkInfra.PixClaim.update!(pix_claim.id, "canceled", reason: "fraud")

    assert !is_nil(claim.id)
  end

  def example_pix_claim() do
    pix_key = StarkInfra.PixKey.query!(limit: 1) |> Enum.take(1) |> hd()

    %StarkInfra.PixClaim{
      account_created: DateTime.utc_now(),
      account_number: "0000-1",
      account_type: "savings",
      branch_code: "0001",
      name: "Pix Claim",
      tax_id: pix_key.tax_id,
      key_id: "+55" <> to_string(Enum.random(10..99)) <> to_string(Enum.random(100000000..999999999))
    }
  end
end
