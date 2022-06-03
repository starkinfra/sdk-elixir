defmodule StarkInfraTest.PixRequest do
  use ExUnit.Case

  @tag :pix_request
  test "create pix request" do
    {:ok, requests} = StarkInfra.PixRequest.create([example_pix_request()])
    request = requests |> hd()

    assert !is_nil(request.id)
  end

  @tag :pix_request
  test "create! pix request" do
    request = StarkInfra.PixRequest.create!([example_pix_request()])
    |> hd()

    assert !is_nil(request.id)
  end

  @tag :pix_request
  test "get pix request" do
    pix_request = StarkInfra.PixRequest.query!(limit: 1)
    |> Enum.take(1)
    |> hd()

    {:ok, request} = StarkInfra.PixRequest.get(pix_request.id)

    assert !is_nil(request.id)
  end

  @tag :pix_request
  test "get! pix request" do
    pix_request = StarkInfra.PixRequest.query!(limit: 1)
      |> Enum.take(1)
      |> hd()
    request = StarkInfra.PixRequest.get!(pix_request.id)

    assert !is_nil(request.id)
  end

  @tag :pix_request
  test "query pix request" do
    StarkInfra.PixRequest.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_request
  test "query! pix request" do
    StarkInfra.PixRequest.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_request
  test "page pix request" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixRequest.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_request
  test "page! pix request" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixRequest.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_request
  test "parse valid pix request" do
    {:ok, {pix_request, pid}} = StarkInfra.PixRequest.parse(
      content: "{\"receiverBranchCode\": \"0001\", \"cashierBankCode\": \"\", \"senderTaxId\": \"20.018.183/0001-80\", \"senderName\": \"Stark Bank S.A. - Instituicao de Pagamento\", \"id\": \"4508348862955520\", \"senderAccountType\": \"payment\", \"fee\": 0, \"receiverName\": \"Cora\", \"cashierType\": \"\", \"externalId\": \"\", \"method\": \"manual\", \"status\": \"processing\", \"updated\": \"2022-02-16T17:23:53.980250+00:00\", \"description\": \"\", \"tags\": [], \"receiverKeyId\": \"\", \"cashAmount\": 0, \"senderBankCode\": \"20018183\", \"senderBranchCode\": \"0001\", \"bankCode\": \"34052649\", \"senderAccountNumber\": \"5647143184367616\", \"receiverAccountNumber\": \"5692908409716736\", \"initiatorTaxId\": \"\", \"receiverTaxId\": \"34.052.649/0001-78\", \"created\": \"2022-02-16T17:23:53.980238+00:00\", \"flow\": \"in\", \"endToEndId\": \"E20018183202202161723Y4cqxlfLFcm\", \"amount\": 1, \"receiverAccountType\": \"checking\", \"reconciliationId\": \"\", \"receiverBankCode\": \"34052649\"}",
      signature: "MEUCIQC7FVhXdripx/aXg5yNLxmNoZlehpyvX3QYDXJ8o02X2QIgVwKfJKuIS5RDq50NC/+55h/7VccDkV1vm8Q/7jNu0VM="
    )

    assert !is_nil(pix_request.id)
    assert !is_nil(pid)
  end

  @tag :pix_request
  test "parse invalida pix request" do
    {:error, errors} = StarkInfra.PixRequest.parse(
      content: "{\"receiverBranchCode\": \"0001\", \"cashierBankCode\": \"\", \"senderTaxId\": \"20.018.183/0001-80\", \"senderName\": \"Stark Bank S.A. - Instituicao de Pagamento\", \"id\": \"4508348862955520\", \"senderAccountType\": \"payment\", \"fee\": 0, \"receiverName\": \"Cora\", \"cashierType\": \"\", \"externalId\": \"\", \"method\": \"manual\", \"status\": \"processing\", \"updated\": \"2022-02-16T17:23:53.980250+00:00\", \"description\": \"\", \"tags\": [], \"receiverKeyId\": \"\", \"cashAmount\": 0, \"senderBankCode\": \"20018183\", \"senderBranchCode\": \"0001\", \"bankCode\": \"34052649\", \"senderAccountNumber\": \"5647143184367616\", \"receiverAccountNumber\": \"5692908409716736\", \"initiatorTaxId\": \"\", \"receiverTaxId\": \"34.052.649/0001-78\", \"created\": \"2022-02-16T17:23:53.980238+00:00\", \"flow\": \"in\", \"endToEndId\": \"E20018183202202161723Y4cqxlfLFcm\", \"amount\": 1, \"receiverAccountType\": \"checking\", \"reconciliationId\": \"\", \"receiverBankCode\": \"34052649\"}",
      signature: "MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk="
    )

    Enum.each(errors, fn error ->
      assert error.code === "invalidSignature"
    end)
  end

  @tag :pix_request
  test "parse! valid pix request" do
    {pix_request, pid} = StarkInfra.PixRequest.parse!(
      content: "{\"receiverBranchCode\": \"0001\", \"cashierBankCode\": \"\", \"senderTaxId\": \"20.018.183/0001-80\", \"senderName\": \"Stark Bank S.A. - Instituicao de Pagamento\", \"id\": \"4508348862955520\", \"senderAccountType\": \"payment\", \"fee\": 0, \"receiverName\": \"Cora\", \"cashierType\": \"\", \"externalId\": \"\", \"method\": \"manual\", \"status\": \"processing\", \"updated\": \"2022-02-16T17:23:53.980250+00:00\", \"description\": \"\", \"tags\": [], \"receiverKeyId\": \"\", \"cashAmount\": 0, \"senderBankCode\": \"20018183\", \"senderBranchCode\": \"0001\", \"bankCode\": \"34052649\", \"senderAccountNumber\": \"5647143184367616\", \"receiverAccountNumber\": \"5692908409716736\", \"initiatorTaxId\": \"\", \"receiverTaxId\": \"34.052.649/0001-78\", \"created\": \"2022-02-16T17:23:53.980238+00:00\", \"flow\": \"in\", \"endToEndId\": \"E20018183202202161723Y4cqxlfLFcm\", \"amount\": 1, \"receiverAccountType\": \"checking\", \"reconciliationId\": \"\", \"receiverBankCode\": \"34052649\"}",
      signature: "MEUCIQC7FVhXdripx/aXg5yNLxmNoZlehpyvX3QYDXJ8o02X2QIgVwKfJKuIS5RDq50NC/+55h/7VccDkV1vm8Q/7jNu0VM="
    )
    assert !is_nil(pix_request.id)
    assert !is_nil(pid)
  end

  @tag :pix_request
  test "parse! invalid pix request" do
    {:error, errors} = StarkInfra.PixRequest.parse(
      content: "{\"receiverBranchCode\": \"0001\", \"cashierBankCode\": \"\", \"senderTaxId\": \"20.018.183/0001-80\", \"senderName\": \"Stark Bank S.A. - Instituicao de Pagamento\", \"id\": \"4508348862955520\", \"senderAccountType\": \"payment\", \"fee\": 0, \"receiverName\": \"Cora\", \"cashierType\": \"\", \"externalId\": \"\", \"method\": \"manual\", \"status\": \"processing\", \"updated\": \"2022-02-16T17:23:53.980250+00:00\", \"description\": \"\", \"tags\": [], \"receiverKeyId\": \"\", \"cashAmount\": 0, \"senderBankCode\": \"20018183\", \"senderBranchCode\": \"0001\", \"bankCode\": \"34052649\", \"senderAccountNumber\": \"5647143184367616\", \"receiverAccountNumber\": \"5692908409716736\", \"initiatorTaxId\": \"\", \"receiverTaxId\": \"34.052.649/0001-78\", \"created\": \"2022-02-16T17:23:53.980238+00:00\", \"flow\": \"in\", \"endToEndId\": \"E20018183202202161723Y4cqxlfLFcm\", \"amount\": 1, \"receiverAccountType\": \"checking\", \"reconciliationId\": \"\", \"receiverBankCode\": \"34052649\"}",
      signature: "MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk="
    )

    Enum.each(errors, fn error ->
      assert error.code === "invalidSignature"
    end)
  end

  def example_pix_request() do
    %StarkInfra.PixRequest{
      amount: 100,
      external_id: StarkInfraTest.Utils.Random.random_string(32),
      sender_account_number: "5692908409716736",
      sender_branch_code: "0001",
      sender_account_type: "checking",
      sender_name: "Jon Snow",
      sender_tax_id: "34.052.649/0001-78",
      receiver_bank_code: "34052649",
      receiver_account_number: "5692908409716736",
      receiver_branch_code: "0001",
      receiver_account_type: "checking",
      receiver_name: "Jamie Lamister",
      receiver_tax_id: "34.052.649/0001-78",
      end_to_end_id: StarkInfra.Utils.EndToEndId.create("35547753")
    }
  end
end
