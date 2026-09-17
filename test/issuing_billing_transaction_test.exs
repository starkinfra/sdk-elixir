defmodule StarkInfraTest.IssuingBillingTransaction do
  use ExUnit.Case

  @tag :issuing_billing_transaction
  test "query issuing billing transaction" do
    StarkInfra.IssuingBillingTransaction.query(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_billing_transaction
  test "query! issuing billing transaction" do
    StarkInfra.IssuingBillingTransaction.query!(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_billing_transaction
  test "query! issuing billing transaction filtered by invoice_id" do
    invoice =
      StarkInfra.IssuingBillingInvoice.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    StarkInfra.IssuingBillingTransaction.query!(limit: 10, invoice_id: invoice.id)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_billing_transaction
  test "page issuing billing transaction" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingBillingTransaction.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_billing_transaction
  test "page! issuing billing transaction" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingBillingTransaction.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
