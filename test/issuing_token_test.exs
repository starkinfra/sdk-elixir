defmodule StarkInfraTest.IssuingToken do
  use ExUnit.Case

  # The sandbox project used in this test suite has no IssuingToken records, since tokens are
  # only created through the wallet provisioning flow. query/page are therefore expected to
  # return empty results here.

  @content "{\"deviceName\": \"My phone\", \"methodCode\": \"manual\", \"walletName\": \"Google Pay\", \"activationCode\": \"\", \"deviceSerialNumber\": \"2F6D63\", \"deviceImei\": \"352099001761481\", \"deviceType\": \"Phone\", \"walletInstanceId\": \"1b24f24a24ba98e27d43e345b532a245e4723d7a9c4f624e\", \"deviceOsVersion\": \"4.4.4\", \"cardId\": \"5189831499972623\", \"deviceOsName\": \"Android\", \"merchantId\": \"12345678901\", \"walletId\": \"google\"}"
  @valid_signature "MEYCIQC4XbhjxEp9VhowLeg9JbSOo94FCRWE9GI7l7OuHh0bUwIhAJBuLDl5DAT9L4iMI0qYQ+PVmBIG5scxxvkWSsoWmwi4"
  @invalid_signature "MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk="
  @malformed_signature "something is definitely wrong"

  @tag :issuing_token
  test "query issuing token test" do
    tokens = StarkInfra.IssuingToken.query(limit: 10) |> Enum.take(10)
    assert tokens == []
  end

  @tag :issuing_token
  test "query! issuing token test" do
    tokens = StarkInfra.IssuingToken.query!(limit: 10) |> Enum.take(10)
    assert tokens == []
  end

  @tag :issuing_token
  test "page issuing token test" do
    {:ok, {cursor, tokens}} = StarkInfra.IssuingToken.page(limit: 10)
    assert tokens == []
    assert is_nil(cursor)
  end

  @tag :issuing_token
  test "page! issuing token test" do
    {cursor, tokens} = StarkInfra.IssuingToken.page!(limit: 10)
    assert tokens == []
    assert is_nil(cursor)
  end

  @tag :issuing_token
  test "parse issuing token test" do
    {:ok, {token, _cache_pid}} =
      StarkInfra.IssuingToken.parse(
        content: @content,
        signature: @valid_signature
      )

    assert !is_nil(token)
  end

  @tag :issuing_token
  test "parse! issuing token test" do
    {token, _cache_pid} =
      StarkInfra.IssuingToken.parse!(
        content: @content,
        signature: @valid_signature
      )

    assert !is_nil(token)
  end

  @tag :issuing_token
  test "parse bad signature issuing token test" do
    {:error, [error]} =
      StarkInfra.IssuingToken.parse(
        content: @content,
        signature: @invalid_signature
      )

    assert error.code == "invalidSignature"
  end

  @tag :issuing_token
  test "parse malformed signature issuing token test" do
    {:error, [error]} =
      StarkInfra.IssuingToken.parse(
        content: @content,
        signature: @malformed_signature
      )

    assert error.code == "invalidSignature"
  end

  @tag :issuing_token
  test "parse! bad signature issuing token test" do
    assert_raise RuntimeError, fn ->
      StarkInfra.IssuingToken.parse!(
        content: @content,
        signature: @invalid_signature
      )
    end
  end

  @tag :issuing_token
  test "parse! malformed signature issuing token test" do
    assert_raise RuntimeError, fn ->
      StarkInfra.IssuingToken.parse!(
        content: @content,
        signature: @malformed_signature
      )
    end
  end

  @tag :issuing_token
  test "response authorization approved issuing token test" do
    response =
      StarkInfra.IssuingToken.response_authorization!(
        "approved",
        activation_methods: [
          %{"type" => "app", "value" => "com.subissuer.android"},
          %{"type" => "text", "value" => "** *****-5678"}
        ],
        design_id: "4584031664472031",
        tags: ["tony", "stark"]
      )

    decoded = Jason.decode!(response)
    assert decoded["authorization"]["status"] == "approved"
    assert decoded["authorization"]["designId"] == "4584031664472031"
    assert decoded["authorization"]["tags"] == ["tony", "stark"]

    assert decoded["authorization"]["activationMethods"] == [
      %{"type" => "app", "value" => "com.subissuer.android"},
      %{"type" => "text", "value" => "** *****-5678"}
    ]
  end

  @tag :issuing_token
  test "response authorization denied issuing token test" do
    response = StarkInfra.IssuingToken.response_authorization!("denied", reason: "other")

    decoded = Jason.decode!(response)
    assert decoded["authorization"]["status"] == "denied"
    assert decoded["authorization"]["reason"] == "other"
  end

  @tag :issuing_token
  test "response activation approved issuing token test" do
    response = StarkInfra.IssuingToken.response_activation!("approved", tags: ["tony", "stark"])

    decoded = Jason.decode!(response)
    assert decoded["authorization"]["status"] == "approved"
    assert decoded["authorization"]["tags"] == ["tony", "stark"]
  end

  @tag :issuing_token
  test "response activation denied issuing token test" do
    response =
      StarkInfra.IssuingToken.response_activation!(
        "denied",
        reason: "other",
        tags: ["tony", "stark"]
      )

    decoded = Jason.decode!(response)
    assert decoded["authorization"]["status"] == "denied"
    assert decoded["authorization"]["reason"] == "other"
  end
end
