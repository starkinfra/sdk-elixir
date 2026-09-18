defmodule StarkInfraTest.BusinessAccountRequest do
  use ExUnit.Case

  @tag :business_account_request
  test "create business account request" do
    {:ok, requests} =
      StarkInfra.BusinessAccountRequest.create(
        [StarkInfraTest.Utils.BusinessAccountRequest.generate_example_business_account_request()],
        user: StarkInfraTest.Utils.BusinessAccountRequest.project()
      )

    request = requests |> hd
    assert !is_nil(request.id)
  end

  @tag :business_account_request
  test "create! business account request" do
    request =
      StarkInfra.BusinessAccountRequest.create!(
        [StarkInfraTest.Utils.BusinessAccountRequest.generate_example_business_account_request()],
        user: StarkInfraTest.Utils.BusinessAccountRequest.project()
      )
      |> hd

    assert !is_nil(request.id)
  end

  @tag :business_account_request
  test "get a business account request" do
    project = StarkInfraTest.Utils.BusinessAccountRequest.project()

    request =
      StarkInfra.BusinessAccountRequest.create!(
        [StarkInfraTest.Utils.BusinessAccountRequest.generate_example_business_account_request()],
        user: project
      )
      |> hd

    {:ok, fetched} = StarkInfra.BusinessAccountRequest.get(request.id, user: project)

    assert fetched.id == request.id
  end

  @tag :business_account_request
  test "get! a business account request" do
    project = StarkInfraTest.Utils.BusinessAccountRequest.project()

    request =
      StarkInfra.BusinessAccountRequest.create!(
        [StarkInfraTest.Utils.BusinessAccountRequest.generate_example_business_account_request()],
        user: project
      )
      |> hd

    fetched = StarkInfra.BusinessAccountRequest.get!(request.id, user: project)

    assert fetched.id == request.id
  end

  @tag :business_account_request
  test "query business account requests" do
    StarkInfra.BusinessAccountRequest.query!(limit: 1, user: StarkInfraTest.Utils.BusinessAccountRequest.project())
    |> Enum.take(1)
    |> (fn list -> assert length(list) <= 1 end).()
  end

  @tag :business_account_request
  test "query! business account requests" do
    StarkInfra.BusinessAccountRequest.query!(limit: 1, user: StarkInfraTest.Utils.BusinessAccountRequest.project())
    |> Enum.take(1)
    |> (fn list -> assert length(list) <= 1 end).()
  end

  @tag :business_account_request
  test "page business account requests" do
    {:ok, ids} =
      StarkInfraTest.Utils.Page.get(
        &StarkInfra.BusinessAccountRequest.page/1,
        2,
        limit: 5,
        user: StarkInfraTest.Utils.BusinessAccountRequest.project()
      )

    assert length(ids) <= 10
  end

  @tag :business_account_request
  test "page! business account requests" do
    ids =
      StarkInfraTest.Utils.Page.get!(
        &StarkInfra.BusinessAccountRequest.page!/1,
        2,
        limit: 5,
        user: StarkInfraTest.Utils.BusinessAccountRequest.project()
      )

    assert length(ids) <= 10
  end
end
