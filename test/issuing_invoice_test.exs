defmodule StarkInfraTest.IssuingInvoice do
  use ExUnit.Case

  @tag :issuing_invoice
  test "create issuing invoice test" do
    {:ok, issuing_invoice} = StarkInfra.IssuingInvoice.create(StarkInfraTest.Utils.IssuingInvoice.example_issuing_invoice())
    {:ok, invoice} = StarkInfra.IssuingInvoice.get(issuing_invoice.id)

    assert issuing_invoice.id == invoice.id
  end

  @tag :issuing_invoice
  test "create! issuing invoice test" do
    issuing_invoice = StarkInfra.IssuingInvoice.create!(StarkInfraTest.Utils.IssuingInvoice.example_issuing_invoice())
    {:ok, invoice} = StarkInfra.IssuingInvoice.get(issuing_invoice.id)

    assert issuing_invoice.id == invoice.id
  end

  @tag :issuing_invoice
  test "get issuing invoice test" do
    invoices = StarkInfra.IssuingInvoice.query!(limit: 5)
    Enum.each(invoices, fn invoice ->
      {:ok, issuing_invoice} = StarkInfra.IssuingInvoice.get(invoice.id)
      assert invoice.id == issuing_invoice.id
    end)
  end

  @tag :issuing_invoice
  test "get! issuing invoice test" do
    invoices = StarkInfra.IssuingInvoice.query!(limit: 5)
    Enum.each(invoices, fn invoice ->
      issuing_invoice = StarkInfra.IssuingInvoice.get!(invoice.id)
      assert invoice.id == issuing_invoice.id
    end)
  end

  @tag :issuing_invoice
  test "query issuing invoice test" do
    issuing_invoices = StarkInfra.IssuingInvoice.query(limit: 10)
      |> Enum.take(10)

    Enum.each(issuing_invoices, fn invoice ->
      {:ok, invoice} = invoice
      assert invoice.id == StarkInfra.IssuingInvoice.get!(invoice.id).id
    end)

    assert length(issuing_invoices) <= 10
  end

  @tag :issuing_invoice
  test "query! issuing invoice test" do
    issuing_invoices = StarkInfra.IssuingInvoice.query!(limit: 10)
      |> Enum.take(10)

    Enum.each(issuing_invoices, fn invoice ->
      assert invoice.id == StarkInfra.IssuingInvoice.get!(invoice.id).id
    end)

    assert length(issuing_invoices) <= 10
  end

  @tag :issuing_invoice
  test "page issuing invoice test" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingInvoice.page/1, 2, limit: 5)

    Enum.each(ids, fn id ->
      assert id == StarkInfra.IssuingInvoice.get!(id).id
    end)

    assert length(ids) <= 10
  end

  @tag :issuing_invoice
  test "page! issuing invoice test" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingInvoice.page!/1, 2, limit: 5)

    Enum.each(ids, fn id ->
      assert id == StarkInfra.IssuingInvoice.get!(id).id
    end)

    assert length(ids) <= 10
  end
end
