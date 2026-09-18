defmodule StarkInfraTest.IndividualAccountRequest.Log do
  use ExUnit.Case

  alias StarkInfraTest.Utils.IndividualAccountRequest, as: Fixture

  setup_all do
    {:ok, user_opts: Fixture.user_opts()}
  end

  @tag :individual_account_request_log
  test "query individual account request log", %{user_opts: user_opts} do
    StarkInfra.IndividualAccountRequest.create!([Fixture.generate_example_individual_account_request()], user_opts)

    StarkInfra.IndividualAccountRequest.Log.query([limit: 101] ++ user_opts)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_account_request_log
  test "query! individual account request log", %{user_opts: user_opts} do
    StarkInfra.IndividualAccountRequest.create!([Fixture.generate_example_individual_account_request()], user_opts)

    StarkInfra.IndividualAccountRequest.Log.query!([limit: 101] ++ user_opts)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_account_request_log
  test "page individual account request log", %{user_opts: user_opts} do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IndividualAccountRequest.Log.page/1, 2, [limit: 5] ++ user_opts)
    assert length(ids) <= 10
  end

  @tag :individual_account_request_log
  test "page! individual account request log", %{user_opts: user_opts} do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IndividualAccountRequest.Log.page!/1, 2, [limit: 5] ++ user_opts)
    assert length(ids) <= 10
  end

  @tag :individual_account_request_log
  test "get individual account request log", %{user_opts: user_opts} do
    StarkInfra.IndividualAccountRequest.create!([Fixture.generate_example_individual_account_request()], user_opts)

    log =
      StarkInfra.IndividualAccountRequest.Log.query!([limit: 1] ++ user_opts)
      |> Enum.take(1)

    assert log != [], "no IndividualAccountRequest log in sandbox"
    log = log |> hd()

    {:ok, unique_log} = StarkInfra.IndividualAccountRequest.Log.get(log.id, user_opts)
    assert unique_log.id == log.id
    assert unique_log.request.id == log.request.id
  end

  @tag :individual_account_request_log
  test "get! individual account request log", %{user_opts: user_opts} do
    StarkInfra.IndividualAccountRequest.create!([Fixture.generate_example_individual_account_request()], user_opts)

    log =
      StarkInfra.IndividualAccountRequest.Log.query!([limit: 1] ++ user_opts)
      |> Enum.take(1)

    assert log != [], "no IndividualAccountRequest log in sandbox"
    log = log |> hd()

    unique_log = StarkInfra.IndividualAccountRequest.Log.get!(log.id, user_opts)
    assert unique_log.id == log.id
  end
end
