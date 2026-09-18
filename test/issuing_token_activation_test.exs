defmodule StarkInfraTest.IssuingTokenActivation do
  use ExUnit.Case

  @content "{\"activationMethod\": {\"type\": \"text\", \"value\": \"** *****-5678\"}, \"tokenId\": \"5585821789122165\", \"tags\": [\"token\", \"user/1234\"], \"cardId\": \"5189831499972623\"}"
  @valid_signature "MEUCIAxn0FmsPWI4r3Y7Nq8xFNQHYZgo0QAGDQ4/7CajKoVuAiEA09kXWrPMhsw4JbgC3pmNccCWr+hidfop/KsSNqza0yE="
  @invalid_signature "MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk="
  @malformed_signature "something is definitely wrong"

  @tag :issuing_token_activation
  test "parse issuing token activation test" do
    {:ok, {activation, _cache_pid}} =
      StarkInfra.IssuingTokenActivation.parse(
        content: @content,
        signature: @valid_signature
      )

    assert !is_nil(activation)
  end

  @tag :issuing_token_activation
  test "parse! issuing token activation test" do
    {activation, _cache_pid} =
      StarkInfra.IssuingTokenActivation.parse!(
        content: @content,
        signature: @valid_signature
      )

    assert !is_nil(activation)
  end

  @tag :issuing_token_activation
  test "parse bad signature issuing token activation test" do
    {:error, [error]} =
      StarkInfra.IssuingTokenActivation.parse(
        content: @content,
        signature: @invalid_signature
      )

    assert error.code == "invalidSignature"
  end

  @tag :issuing_token_activation
  test "parse malformed signature issuing token activation test" do
    {:error, [error]} =
      StarkInfra.IssuingTokenActivation.parse(
        content: @content,
        signature: @malformed_signature
      )

    assert error.code == "invalidSignature"
  end

  @tag :issuing_token_activation
  test "parse! bad signature issuing token activation test" do
    assert_raise RuntimeError, fn ->
      StarkInfra.IssuingTokenActivation.parse!(
        content: @content,
        signature: @invalid_signature
      )
    end
  end

  @tag :issuing_token_activation
  test "parse! malformed signature issuing token activation test" do
    assert_raise RuntimeError, fn ->
      StarkInfra.IssuingTokenActivation.parse!(
        content: @content,
        signature: @malformed_signature
      )
    end
  end
end
