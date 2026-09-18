defmodule StarkInfraTest.IndividualAccountRequest do
  use ExUnit.Case

  alias StarkInfraTest.Utils.IndividualAccountRequest, as: Fixture

  setup_all do
    {:ok, user_opts: Fixture.user_opts()}
  end

  @tag :individual_account_request
  test "create individual account request", %{user_opts: user_opts} do
    {:ok, requests} = StarkInfra.IndividualAccountRequest.create([Fixture.generate_example_individual_account_request()], user_opts)
    request = requests |> hd
    assert !is_nil(request.id)
    assert request.account_type == "individual"
  end

  @tag :individual_account_request
  test "create! individual account request", %{user_opts: user_opts} do
    request = StarkInfra.IndividualAccountRequest.create!([Fixture.generate_example_individual_account_request()], user_opts) |> hd
    assert !is_nil(request.id)
  end

  @tag :individual_account_request
  test "get individual account request", %{user_opts: user_opts} do
    created = StarkInfra.IndividualAccountRequest.create!([Fixture.generate_example_individual_account_request()], user_opts) |> hd

    {:ok, retrieved} = StarkInfra.IndividualAccountRequest.get(created.id, user_opts)

    assert retrieved.id == created.id
  end

  @tag :individual_account_request
  test "get! individual account request", %{user_opts: user_opts} do
    created = StarkInfra.IndividualAccountRequest.create!([Fixture.generate_example_individual_account_request()], user_opts) |> hd

    retrieved = StarkInfra.IndividualAccountRequest.get!(created.id, user_opts)

    assert retrieved.id == created.id
  end

  @tag :individual_account_request
  test "query individual account request", %{user_opts: user_opts} do
    StarkInfra.IndividualAccountRequest.query!([limit: 101, before: DateTime.utc_now()] ++ user_opts)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_account_request
  test "query! individual account request", %{user_opts: user_opts} do
    StarkInfra.IndividualAccountRequest.query!([limit: 101, before: DateTime.utc_now()] ++ user_opts)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_account_request
  test "page individual account request", %{user_opts: user_opts} do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IndividualAccountRequest.page/1, 2, [limit: 5] ++ user_opts)
    assert length(ids) <= 10
  end

  @tag :individual_account_request
  test "page! individual account request", %{user_opts: user_opts} do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IndividualAccountRequest.page!/1, 2, [limit: 5] ++ user_opts)
    assert length(ids) <= 10
  end

  @tag :individual_account_request
  test "update individual account request name", %{user_opts: user_opts} do
    created = StarkInfra.IndividualAccountRequest.create!([Fixture.generate_example_individual_account_request()], user_opts) |> hd

    {:ok, updated} = StarkInfra.IndividualAccountRequest.update(created.id, [name: created.name] ++ user_opts)

    assert updated.id == created.id
  end

  @tag :individual_account_request
  test "update! individual account request address", %{user_opts: user_opts} do
    created = StarkInfra.IndividualAccountRequest.create!([Fixture.generate_example_individual_account_request()], user_opts) |> hd

    updated = StarkInfra.IndividualAccountRequest.update!(
      created.id,
      [address: Fixture.generate_example_address()] ++ user_opts
    )

    assert updated.id == created.id
  end
end
