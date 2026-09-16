defmodule StarkInfraTest.IssuingBillingInvoice do
  use ExUnit.Case

  @tag :issuing_billing_invoice
  test "query issuing billing invoice" do
    StarkInfra.IssuingBillingInvoice.query(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_billing_invoice
  test "query! issuing billing invoice" do
    StarkInfra.IssuingBillingInvoice.query!(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_billing_invoice
  test "get issuing billing invoice" do
    StarkInfra.IssuingBillingInvoice.query!(limit: 1)
    |> Enum.take(1)
    |> Enum.each(fn invoice ->
      {:ok, retrieved_invoice} = StarkInfra.IssuingBillingInvoice.get(invoice.id)
      assert invoice.id == retrieved_invoice.id
    end)
  end

  @tag :issuing_billing_invoice
  test "get! issuing billing invoice" do
    StarkInfra.IssuingBillingInvoice.query!(limit: 1)
    |> Enum.take(1)
    |> Enum.each(fn invoice ->
      assert invoice.id == StarkInfra.IssuingBillingInvoice.get!(invoice.id).id
    end)
  end

  @tag :issuing_billing_invoice
  test "page issuing billing invoice" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingBillingInvoice.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_billing_invoice
  test "page! issuing billing invoice" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingBillingInvoice.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
