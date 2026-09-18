defmodule StarkInfraTest.BusinessAccountRequest.Log do
  use ExUnit.Case

  @tag :business_account_request_log
  test "get business account request log" do
    project = StarkInfraTest.Utils.BusinessAccountRequest.project()

    StarkInfra.BusinessAccountRequest.create!(
      [StarkInfraTest.Utils.BusinessAccountRequest.generate_example_business_account_request()],
      user: project
    )

    log =
      StarkInfra.BusinessAccountRequest.Log.query!(limit: 1, user: project)
      |> Enum.take(1)
      |> hd()

    {:ok, unique_log} = StarkInfra.BusinessAccountRequest.Log.get(log.id, user: project)
    assert unique_log.id == log.id
  end

  @tag :business_account_request_log
  test "get! business account request log" do
    project = StarkInfraTest.Utils.BusinessAccountRequest.project()

    StarkInfra.BusinessAccountRequest.create!(
      [StarkInfraTest.Utils.BusinessAccountRequest.generate_example_business_account_request()],
      user: project
    )

    log =
      StarkInfra.BusinessAccountRequest.Log.query!(limit: 1, user: project)
      |> Enum.take(1)
      |> hd()

    unique_log = StarkInfra.BusinessAccountRequest.Log.get!(log.id, user: project)
    assert unique_log.id == log.id
  end

  @tag :business_account_request_log
  test "query business account request log" do
    project = StarkInfraTest.Utils.BusinessAccountRequest.project()

    StarkInfra.BusinessAccountRequest.create!(
      [StarkInfraTest.Utils.BusinessAccountRequest.generate_example_business_account_request()],
      user: project
    )

    StarkInfra.BusinessAccountRequest.Log.query!(limit: 1, user: project)
    |> Enum.take(1)
    |> (fn list -> assert length(list) <= 1 end).()
  end

  @tag :business_account_request_log
  test "query! business account request log" do
    project = StarkInfraTest.Utils.BusinessAccountRequest.project()

    StarkInfra.BusinessAccountRequest.create!(
      [StarkInfraTest.Utils.BusinessAccountRequest.generate_example_business_account_request()],
      user: project
    )

    StarkInfra.BusinessAccountRequest.Log.query!(limit: 1, user: project)
    |> Enum.take(1)
    |> (fn list -> assert length(list) <= 1 end).()
  end

  @tag :business_account_request_log
  test "page business account request log" do
    project = StarkInfraTest.Utils.BusinessAccountRequest.project()

    StarkInfra.BusinessAccountRequest.create!(
      [StarkInfraTest.Utils.BusinessAccountRequest.generate_example_business_account_request()],
      user: project
    )

    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.BusinessAccountRequest.Log.page/1, 2, limit: 5, user: project)
    assert length(ids) <= 10
  end

  @tag :business_account_request_log
  test "page! business account request log" do
    project = StarkInfraTest.Utils.BusinessAccountRequest.project()

    StarkInfra.BusinessAccountRequest.create!(
      [StarkInfraTest.Utils.BusinessAccountRequest.generate_example_business_account_request()],
      user: project
    )

    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.BusinessAccountRequest.Log.page!/1, 2, limit: 5, user: project)
    assert length(ids) <= 10
  end
end
