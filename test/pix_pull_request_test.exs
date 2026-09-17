defmodule StarkInfraTest.PixPullRequest do
  use ExUnit.Case

  @tag :pix_pull_request
  test "create pix pull request" do
    {:ok, pix_pull_requests} =
      StarkInfra.PixPullRequest.create([StarkInfraTest.Utils.PixPullRequest.example_pix_pull_request()])

    pix_pull_request = pix_pull_requests |> hd
    assert !is_nil(pix_pull_request.id)
  end

  @tag :pix_pull_request
  test "create! pix pull request" do
    pix_pull_request =
      StarkInfra.PixPullRequest.create!([StarkInfraTest.Utils.PixPullRequest.example_pix_pull_request()])
      |> hd

    assert !is_nil(pix_pull_request.id)
  end

  @tag :pix_pull_request
  test "get pix pull request" do
    pix_pull_request =
      StarkInfra.PixPullRequest.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, request} = StarkInfra.PixPullRequest.get(pix_pull_request.id)

    assert !is_nil(request.id)
  end

  @tag :pix_pull_request
  test "get! pix pull request" do
    pix_pull_request =
      StarkInfra.PixPullRequest.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    request = StarkInfra.PixPullRequest.get!(pix_pull_request.id)

    assert !is_nil(request.id)
  end

  @tag :pix_pull_request
  test "query pix pull request" do
    StarkInfra.PixPullRequest.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_pull_request
  test "query! pix pull request" do
    StarkInfra.PixPullRequest.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_pull_request
  test "page pix pull request" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixPullRequest.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_pull_request
  test "page! pix pull request" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixPullRequest.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  # Every PixPullRequest in this sandbox Workspace has flow "out" (we are always the receiver).
  # Updating a PixPullRequest is a payer-only action, so the API is expected to deny it here.
  # This is a genuine, reproducible sandbox/role limitation, not a flaky assertion.
  @tag :pix_pull_request
  test "update pix pull request as receiver is denied by the API" do
    pix_pull_request =
      StarkInfra.PixPullRequest.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:error, [error]} =
      StarkInfra.PixPullRequest.update(
        pix_pull_request.id,
        "denied",
        reason: "senderAccountClosed"
      )

    assert error.code == "invalidAction"
  end

  @tag :pix_pull_request
  test "update! pix pull request as receiver raises" do
    pix_pull_request =
      StarkInfra.PixPullRequest.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    assert_raise RuntimeError, ~r/invalidAction/, fn ->
      StarkInfra.PixPullRequest.update!(
        pix_pull_request.id,
        "denied",
        reason: "senderAccountClosed"
      )
    end
  end

  @tag :pix_pull_request
  test "cancel pix pull request" do
    pix_pull_request =
      StarkInfra.PixPullRequest.create!([StarkInfraTest.Utils.PixPullRequest.example_pix_pull_request()])
      |> hd()

    {:ok, canceled} = StarkInfra.PixPullRequest.cancel(pix_pull_request.id, "receiverUserRequested")

    assert canceled.id == pix_pull_request.id
  end

  @tag :pix_pull_request
  test "cancel! pix pull request" do
    pix_pull_request =
      StarkInfra.PixPullRequest.create!([StarkInfraTest.Utils.PixPullRequest.example_pix_pull_request()])
      |> hd()

    canceled = StarkInfra.PixPullRequest.cancel!(pix_pull_request.id, "receiverUserRequested")

    assert canceled.id == pix_pull_request.id
  end
end
