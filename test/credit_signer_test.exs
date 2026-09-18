defmodule StarkInfraTest.CreditSigner do
  use ExUnit.Case

  @tag :credit_signer
  test "resend token to credit signer" do
    signer = pending_signer()
    {:ok, updated_signer} = StarkInfra.CreditSigner.resend_token(signer.id)
    assert updated_signer.id == signer.id
    assert %StarkInfra.CreditSigner{} = updated_signer
  end

  @tag :credit_signer
  test "resend! token to credit signer" do
    signer = pending_signer()
    updated_signer = StarkInfra.CreditSigner.resend_token!(signer.id)
    assert updated_signer.id == signer.id
    assert is_nil(updated_signer.signed)
  end

  # a signer of a CreditNote still waiting for signatures
  defp pending_signer() do
    notes =
      StarkInfra.CreditNote.query!(limit: 10, status: "created")
      |> Enum.take(10)
      |> Enum.filter(fn note -> note.signers != [] end)

    assert notes != [], "no CreditNote in created status with signers in the sandbox"
    notes |> hd() |> Map.get(:signers) |> hd()
  end
end
