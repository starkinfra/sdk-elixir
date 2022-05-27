defmodule StarkInfraTest.IssuingAuthorization do
    use ExUnit.Case

    @content "{\"acquirerId\": \"236090\", \"amount\": 100, \"cardId\": \"5671893688385536\", \"cardTags\": [], \"endToEndId\": \"2fa7ef9f-b889-4bae-ac02-16749c04a3b6\", \"holderId\": \"5917814565109760\", \"holderTags\": [], \"isPartialAllowed\": false, \"issuerAmount\": 100, \"issuerCurrencyCode\": \"BRL\", \"merchantAmount\": 100, \"merchantCategoryCode\": \"bookStores\", \"merchantCountryCode\": \"BRA\", \"merchantCurrencyCode\": \"BRL\", \"merchantFee\": 0, \"merchantId\": \"204933612653639\", \"merchantName\": \"COMPANY 123\", \"methodCode\": \"token\", \"purpose\": \"purchase\", \"score\": null, \"tax\": 0, \"walletId\": \"\"}"
    @signature "MEUCIBxymWEpit50lDqFKFHYOgyyqvE5kiHERi0ZM6cJpcvmAiEA2wwIkxcsuexh9BjcyAbZxprpRUyjcZJ2vBAjdd7o28Q="
    @bad_signature "MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk="
    @malformed_signature "something is definitely wrong"

    @tag :issuing_authorization
    test "response issuing authorization test" do
        response = StarkInfra.IssuingAuthorization.response!(
            status: "denied"
        )
        assert !is_nil(response)
    end

    @tag :issuing_authorization
    test "parse issuing authorization test" do
        {:ok, {_authorization, cache_pid_1}} = StarkInfra.IssuingAuthorization.parse(
            content: @content,
            signature: @signature
        )

        {:ok, {authorization, cache_pid_2}} =
            StarkInfra.IssuingAuthorization.parse(
                content: @content,
                signature: @signature,
                cache_pid: cache_pid_1
            )

        assert Agent.get(cache_pid_1, fn map -> Map.get(map, :StarkInfra_public_key) end) ==
            Agent.get(cache_pid_2, fn map -> Map.get(map, :StarkInfra_public_key) end)

        assert !is_nil(authorization)
    end

    @tag :issuing_authorization
    test "parse bad signature issuing authorization test" do
        {:error, [error]} =
            StarkInfra.IssuingAuthorization.parse(
                content: @content,
                signature: @bad_signature
            )
        assert error.code == "invalidSignature"
    end

    @tag :issuing_authorization
    test "parse invalid signature issuing authorization test" do
        {:error, [error]} =
            StarkInfra.IssuingAuthorization.parse(
                content: @content,
                signature: @malformed_signature
            )

        assert error.code == "invalidSignature"
    end

    @tag :issuing_authorization
    test "parse! issuing authorization test" do
        {authorization, _cache_pid} = StarkInfra.IssuingAuthorization.parse!(
            content: @content,
            signature: @signature
        )

        assert !is_nil(authorization)
    end

    @tag :issuing_authorization
    test "parse! bad signature issuing authorization test" do
        [error] = StarkInfra.IssuingAuthorization.parse!(
            content: @content,
            signature: @bad_signature
        )
        assert error.code == "invalidSignature"
    end

    @tag :issuing_authorization
    test "parse! invalid signature issuing authorization test" do
        [error] = StarkInfra.IssuingAuthorization.parse(
            content: @content,
            signature: @malformed_signature
        )

        assert error.code == "invalidSignature"
    end
end
