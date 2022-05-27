defmodule StarkInfraTest.Webhook do
    use ExUnit.Case

    @tag :webhook
    test "create, get and delete webhook" do
        {:ok, create_webhook} =
            StarkInfra.Webhook.create(
                url: "https://webhook.site/a10b29fc-45cf-4a09-b743-b7dff8c9eea5",
                subscriptions: ["contract", "credit-note", "signer", "issuing-card", "issuing-invoice", "issuing-purchase", "pix-request.in", "pix-request.out", "pix-reversal.in", "pix-reversal.out", "pix-claim", "pix-key", "pix-chargeback", "pix-infraction"]
            )

        {:ok, get_webhook} = StarkInfra.Webhook.get(create_webhook.id)
        {:ok, delete_webhook} = StarkInfra.Webhook.delete(get_webhook.id)
        assert !is_nil(delete_webhook)
    end

    @tag :webhook
    test "create!, get! and delete! webhook" do
        create_webhook =
            StarkInfra.Webhook.create!(
                url: "https://webhook.site/a10b29fc-45cf-4a09-b743-b7dff8c9eea5",
                subscriptions: ["contract", "credit-note", "signer", "issuing-card", "issuing-invoice", "issuing-purchase", "pix-request.in", "pix-request.out", "pix-reversal.in", "pix-reversal.out", "pix-claim", "pix-key", "pix-chargeback", "pix-infraction"]
            )

        get_webhook = StarkInfra.Webhook.get!(create_webhook.id)
        delete_webhook = StarkInfra.Webhook.delete!(get_webhook.id)
        assert !is_nil(delete_webhook)
    end

    @tag :webhook
    test "query webhook" do
        StarkInfra.Webhook.query(limit: 5)
        |> Enum.take(5)
        |> (fn list -> assert length(list) <= 5 end).()
    end

    @tag :webhook
    test "query! webhook" do
        StarkInfra.Webhook.query!(limit: 5)
        |> Enum.take(5)
        |> (fn list -> assert length(list) <= 5 end).()
    end

    @tag :webhook
    test "page webhook" do
        {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.Webhook.page/1, 2, limit: 2)
        assert length(ids) <= 4
    end

    @tag :webhook
    test "page! webhook" do
        ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.Webhook.page!/1, 2, limit: 2)
        assert length(ids) <= 4
    end

end
