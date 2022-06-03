defmodule StarkInfraTest.WebhookEvent do
  use ExUnit.Case

  @content "{\"event\": {\"created\": \"2022-02-15T20:45:09.852878+00:00\", \"id\": \"5015597159022592\", \"log\": {\"created\": \"2022-02-15T20:45:09.436621+00:00\", \"errors\": [{\"code\": \"insufficientFunds\", \"message\": \"Amount of funds available is not sufficient to cover the specified transfer\"}], \"id\": \"5288053467774976\", \"request\": {\"amount\": 1000, \"bankCode\": \"34052649\", \"cashAmount\": 0, \"cashierBankCode\": \"\", \"cashierType\": \"\", \"created\": \"2022-02-15T20:45:08.210009+00:00\", \"description\": \"For saving my life\", \"endToEndId\": \"E34052649202201272111u34srod1a91\", \"externalId\": \"141322efdgber1ecd1s342341321\", \"fee\": 0, \"flow\": \"out\", \"id\": \"5137269514043392\", \"initiatorTaxId\": \"\", \"method\": \"manual\", \"receiverAccountNumber\": \"000001\", \"receiverAccountType\": \"checking\", \"receiverBankCode\": \"00000001\", \"receiverBranchCode\": \"0001\", \"receiverKeyId\": \"\", \"receiverName\": \"Jamie Lennister\", \"receiverTaxId\": \"45.987.245/0001-92\", \"reconciliationId\": \"\", \"senderAccountNumber\": \"000000\", \"senderAccountType\": \"checking\", \"senderBankCode\": \"34052649\", \"senderBranchCode\": \"0000\", \"senderName\": \"tyrion Lennister\", \"senderTaxId\": \"012.345.678-90\", \"status\": \"failed\", \"tags\": [], \"updated\": \"2022-02-15T20:45:09.436661+00:00\"}, \"type\": \"failed\"}, \"subscription\": \"pix-request.out\", \"workspaceId\": \"5692908409716736\"}}"
  @signature "MEYCIQCmFCAn2Z+6qEHmf8paI08Ee5ZJ9+KvLWSS3ddp8+RF3AIhALlK7ltfRvMCXhjS7cy8SPlcSlpQtjBxmhN6ClFC0Tv6"
  @bad_signature "MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk="
  @malformed_signature "something is definitely wrong"

  @tag :event
  test "get, update and delete webhook event" do
    {:ok, query_event} =
      StarkInfra.Event.query(limit: 1)
      |> Enum.take(1)
      |> hd

    {:ok, get_event} = StarkInfra.Event.get(query_event.id)
    {:ok, delivered_event} = StarkInfra.Event.update(get_event.id, is_delivered: true)
    {:ok, delete_event} = StarkInfra.Event.delete(delivered_event.id)
    assert !is_nil(delete_event.id)
  end

  @tag :event
  test "get!, update! and delete! webhook event" do
    query_event =
      StarkInfra.Event.query!(limit: 1, is_delivered: false)
      |> Enum.take(1)
      |> hd

    get_event = StarkInfra.Event.get!(query_event.id)
    assert !get_event.is_delivered
    delivered_event = StarkInfra.Event.update!(get_event.id, is_delivered: true)
    assert delivered_event.is_delivered
    delete_event = StarkInfra.Event.delete!(delivered_event.id)
    assert !is_nil(delete_event.id)
  end

  @tag :event
  test "query and attempt" do
    for event <- StarkInfra.Event.query!(limit: 2, is_delivered: false) |> Enum.take(2) do
      {:ok, query_attempt} =
        StarkInfra.Event.Attempt.query(event_ids: [event.id], limit: 1)
        |> Enum.take(1)
        |> hd
      {:ok, get_attempt} = StarkInfra.Event.Attempt.get(query_attempt.id)
      assert get_attempt.id == query_attempt.id
    end
  end

  @tag :event
  test "query! and attempt!" do
    for event <- StarkInfra.Event.query!(limit: 2, is_delivered: false) |> Enum.take(2) do
      query_attempt =
        StarkInfra.Event.Attempt.query!(event_ids: [event.id], limit: 1)
        |> Enum.take(1)
        |> hd
      get_attempt = StarkInfra.Event.Attempt.get!(query_attempt.id)
      assert get_attempt.id == query_attempt.id
    end
  end

  @tag :event
  test "page event attempt" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.Event.Attempt.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :event
  test "page! event attempt" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.Event.Attempt.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :event
  test "page event" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.Event.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :event
  test "page! event" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.Event.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :event
  test "query webhook event" do
    StarkInfra.Event.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :event
  test "query! webhook event" do
    StarkInfra.Event.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :event
  test "parse webhook event" do
    {:ok, {_event, cache_pid_1}} =
      StarkInfra.Event.parse(
        content: @content,
        signature: @signature
      )

    {:ok, {event, cache_pid_2}} =
      StarkInfra.Event.parse(
        content: @content,
        signature: @signature,
        cache_pid: cache_pid_1
      )

    assert Agent.get(cache_pid_1, fn map -> Map.get(map, :StarkInfra_public_key) end) ==
      Agent.get(cache_pid_2, fn map -> Map.get(map, :StarkInfra_public_key) end)

    assert !is_nil(event.log)
  end

  @tag :event
  test "parse! webhook event" do
    {_event, cache_pid_1} =
      StarkInfra.Event.parse!(
        content: @content,
        signature: @signature
      )

    {event, cache_pid_2} =
      StarkInfra.Event.parse!(
        content: @content,
        signature: @signature,
        cache_pid: cache_pid_1
      )

    assert Agent.get(cache_pid_1, fn map -> Map.get(map, :StarkInfra_public_key) end) ==
      Agent.get(cache_pid_2, fn map -> Map.get(map, :StarkInfra_public_key) end)

    assert !is_nil(event.log)
  end

  @tag :event
  test "parse webhook event with invalid signature" do
    {:error, [error]} =
      StarkInfra.Event.parse(
        content: @content,
        signature: @bad_signature
      )

    assert error.code == "invalidSignature"
  end

  @tag :event
  test "parse webhook event with malformed signature" do
    {:error, [error]} =
      StarkInfra.Event.parse(
        content: @content,
        signature: @malformed_signature
      )

    assert error.code == "invalidSignature"
  end
end
