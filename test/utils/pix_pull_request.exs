defmodule StarkInfraTest.Utils.PixPullRequest do
  use ExUnit.Case

  def get_active_subscription() do
    {:ok, {_cursor, subscriptions}} =
      StarkInfra.Utils.Rest.get_page({"PixPullSubscription", fn json -> json end}, %{limit: 20, user: nil})

    subscriptions
    |> Enum.map(&Enum.into(&1, %{}))
    |> Enum.find(fn subscription -> subscription.status == "active" end)
    |> case do
      nil -> raise "no active PixPullSubscription found in sandbox to create a PixPullRequest against"
      subscription -> subscription
    end
  end

  def example_pix_pull_request() do
    subscription = get_active_subscription()

    %StarkInfra.PixPullRequest{
      amount: 100,
      due: DateTime.utc_now() |> DateTime.add(5 * 24 * 60 * 60, :second),
      end_to_end_id: StarkInfra.Utils.EndToEndId.create(subscription.receiver_bank_code),
      receiver_account_number: "5692908409716736",
      receiver_account_type: "checking",
      receiver_bank_code: subscription.receiver_bank_code,
      reconciliation_id: "pull" <> (DateTime.utc_now() |> DateTime.to_unix() |> Integer.to_string()),
      subscription_id: subscription.id,
      attempt_type: "default"
    }
  end
end
