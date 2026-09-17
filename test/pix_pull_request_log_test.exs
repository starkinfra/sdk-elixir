defmodule StarkInfraTest.PixPullRequest.Log do
  use ExUnit.Case

  @tag :pix_pull_request_log
  test "get pix pull request log" do
    log =
      StarkInfra.PixPullRequest.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, unique_log} = StarkInfra.PixPullRequest.Log.get(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_pull_request_log
  test "get! pix pull request log" do
    log =
      StarkInfra.PixPullRequest.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    unique_log = StarkInfra.PixPullRequest.Log.get!(log.id)
    assert unique_log.id == log.id
  end

  @tag :pix_pull_request_log
  test "query pix pull request log" do
    StarkInfra.PixPullRequest.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_pull_request_log
  test "query! pix pull request log" do
    StarkInfra.PixPullRequest.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_pull_request_log
  test "query! pix pull request log with filters" do
    pix_pull_request =
      StarkInfra.PixPullRequest.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    StarkInfra.PixPullRequest.Log.query!(request_ids: [pix_pull_request.id])
    |> Enum.take(50)
    |> (fn logs ->
      log = logs |> hd
      assert log.request.id == pix_pull_request.id
    end).()
  end

  @tag :pix_pull_request_log
  test "page pix pull request log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixPullRequest.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_pull_request_log
  test "page! pix pull request log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixPullRequest.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
