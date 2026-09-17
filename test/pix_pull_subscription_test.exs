defmodule StarkInfraTest.PixPullSubscription do
  use ExUnit.Case

  @bad_signature "MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk="
  @malformed_signature "something is definitely wrong"
  @content "{\"bacenId\": \"RR2017032900000000000000003\", \"externalId\": \"my-subscription-001\", \"installmentStart\": \"2026-04-01T12:00:00.000000+00:00\", \"interval\": \"month\", \"receiverName\": \"Edward Stark\", \"receiverTaxId\": \"20.018.183/0001-80\", \"receiverBankCode\": \"20018183\", \"referenceCode\": \"contract-202604\", \"senderAccountNumber\": \"876543-2\", \"senderBankCode\": \"20018183\", \"senderBranchCode\": \"1357-9\", \"senderCityCode\": \"3550308\", \"senderTaxId\": \"012.345.678-90\", \"type\": \"push\", \"amount\": 11234, \"amountMinLimit\": null, \"description\": \"Monthly subscription\", \"due\": null, \"installmentEnd\": null, \"pullRetryLimit\": null, \"senderFinalName\": null, \"senderFinalTaxId\": null, \"tags\": [\"employees\", \"monthly\"], \"id\": \"5656565656565656\", \"status\": \"created\", \"flow\": \"out\", \"created\": \"2026-03-10T10:30:00.000000+00:00\", \"updated\": \"2026-03-10T10:30:00.000000+00:00\"}"

  @tag :pix_pull_subscription
  test "create pix pull subscription" do
    {:ok, subscriptions} = StarkInfra.PixPullSubscription.create([example_pix_pull_subscription()])
    subscription = subscriptions |> hd()

    assert !is_nil(subscription.id)
  end

  @tag :pix_pull_subscription
  test "create! pix pull subscription" do
    subscription = StarkInfra.PixPullSubscription.create!([example_pix_pull_subscription()])
      |> hd()

    assert !is_nil(subscription.id)
  end

  @tag :pix_pull_subscription
  test "query pix pull subscription" do
    StarkInfra.PixPullSubscription.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_pull_subscription
  test "query! pix pull subscription" do
    StarkInfra.PixPullSubscription.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_pull_subscription
  test "get pix pull subscription" do
    pull_subscription = StarkInfra.PixPullSubscription.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, subscription} = StarkInfra.PixPullSubscription.get(pull_subscription.id)

    assert !is_nil(subscription.id)
  end

  @tag :pix_pull_subscription
  test "get! pix pull subscription" do
    pull_subscription = StarkInfra.PixPullSubscription.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    subscription = StarkInfra.PixPullSubscription.get!(pull_subscription.id)

    assert !is_nil(subscription.id)
  end

  @tag :pix_pull_subscription
  test "page pix pull subscription" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixPullSubscription.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_pull_subscription
  test "page! pix pull subscription" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixPullSubscription.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_pull_subscription
  test "update pix pull subscription" do
    subscriptions = StarkInfra.PixPullSubscription.query!(limit: 1, status: "pending") |> Enum.take(1)
    assert subscriptions != [], "no pending PixPullSubscription available in the sandbox"
    pull_subscription = hd(subscriptions)

    {:ok, subscription} = StarkInfra.PixPullSubscription.update(
      pull_subscription.id,
      "confirmed",
      sender_city_code: "3550308"
    )

    assert !is_nil(subscription.id)
  end

  @tag :pix_pull_subscription
  test "update! pix pull subscription" do
    subscriptions = StarkInfra.PixPullSubscription.query!(limit: 1, status: "pending") |> Enum.take(1)
    assert subscriptions != [], "no pending PixPullSubscription available in the sandbox"
    pull_subscription = hd(subscriptions)

    subscription = StarkInfra.PixPullSubscription.update!(
      pull_subscription.id,
      "confirmed",
      sender_city_code: "3550308"
    )

    assert !is_nil(subscription.id)
  end

  @tag :pix_pull_subscription
  test "cancel pix pull subscription" do
    subscriptions = StarkInfra.PixPullSubscription.query!(limit: 1, status: "active") |> Enum.take(1)
    assert subscriptions != [], "no active PixPullSubscription available in the sandbox"
    pull_subscription = hd(subscriptions)

    {:ok, subscription} = StarkInfra.PixPullSubscription.cancel(
      pull_subscription.id,
      reason: "receiverUserRequested"
    )

    assert subscription.status == "canceled"
  end

  @tag :pix_pull_subscription
  test "cancel! pix pull subscription" do
    subscriptions = StarkInfra.PixPullSubscription.query!(limit: 1, status: "active") |> Enum.take(1)
    assert subscriptions != [], "no active PixPullSubscription available in the sandbox"
    pull_subscription = hd(subscriptions)

    subscription = StarkInfra.PixPullSubscription.cancel!(
      pull_subscription.id,
      reason: "receiverUserRequested"
    )

    assert subscription.status == "canceled"
  end

  @tag :pix_pull_subscription
  test "parse pix pull subscription with invalid signature" do
    {:error, errors} = StarkInfra.PixPullSubscription.parse(
      content: @content,
      signature: @bad_signature
    )

    Enum.each(errors, fn error ->
      assert error.code === "invalidSignature"
    end)
  end

  @tag :pix_pull_subscription
  test "parse pix pull subscription with malformed signature" do
    {:error, errors} = StarkInfra.PixPullSubscription.parse(
      content: @content,
      signature: @malformed_signature
    )

    Enum.each(errors, fn error ->
      assert error.code === "invalidSignature"
    end)
  end

  def example_pix_pull_subscription() do
    bank_code = System.get_env("SANDBOX_BANK_CODE")
    %StarkInfra.PixPullSubscription{
      bacen_id: bacen_id(bank_code),
      external_id: StarkInfraTest.Utils.Random.random_string(32),
      installment_start: StarkInfraTest.Utils.Random.get_future_datetime(1),
      interval: "month",
      receiver_name: "Edward Stark",
      receiver_tax_id: "20.018.183/0001-80",
      receiver_bank_code: bank_code,
      reference_code: random_digits(8),
      sender_account_number: "876543-2",
      sender_bank_code: bank_code,
      sender_branch_code: "1357-9",
      # the API rejects the city code on creation for the "push" journey; it is sent on the confirming update
      sender_city_code: nil,
      sender_tax_id: "012.345.678-90",
      type: "push",
      amount: 11234,
      description: "Monthly subscription",
      tags: ["employees", "monthly"]
    }
  end

  # Central Bank recurrence id: "RR" + participant ISPB + YYYYMMDDHHmm + 7 digits
  defp bacen_id(bank_code) do
    "RR" <> bank_code <> Calendar.strftime(DateTime.utc_now(), "%Y%m%d%H%M") <> random_digits(7)
  end

  defp random_digits(length) do
    Enum.map_join(1..length, fn _ -> Integer.to_string(Enum.random(0..9)) end)
  end
end
