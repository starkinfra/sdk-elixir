defmodule StarkInfraTest.PixPullSubscription.Log do
  use ExUnit.Case

  @tag :pix_pull_subscription_log
  test "get pix pull subscription log" do
    log =
      StarkInfra.PixPullSubscription.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, unique_log} = StarkInfra.PixPullSubscription.Log.get(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_pull_subscription_log
  test "get! pix pull subscription log" do
    log =
      StarkInfra.PixPullSubscription.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    unique_log = StarkInfra.PixPullSubscription.Log.get!(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_pull_subscription_log
  test "query pix pull subscription log" do
    StarkInfra.PixPullSubscription.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_pull_subscription_log
  test "query! pix pull subscription log" do
    StarkInfra.PixPullSubscription.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_pull_subscription_log
  test "query! pix pull subscription log with filters" do
    pull_subscription = StarkInfra.PixPullSubscription.query!(limit: 1)
    |> Enum.take(1)
    |> hd()

    StarkInfra.PixPullSubscription.Log.query!(subscription_ids: [pull_subscription.id])
    |> Enum.take(50)
    |> (fn log ->
      log = log |> hd
      assert log.subscription.id == pull_subscription.id
    end).()
  end

  @tag :pix_pull_subscription_log
  test "page pix pull subscription log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixPullSubscription.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_pull_subscription_log
  test "page! pix pull subscription log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixPullSubscription.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
