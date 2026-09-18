defmodule StarkInfraTest.IndividualAccountAttachment do
  use ExUnit.Case

  alias StarkInfraTest.Utils.IndividualAccountRequest, as: RequestFixture
  alias StarkInfraTest.Utils.IndividualAccountAttachment, as: Fixture

  setup_all do
    {:ok, user_opts: RequestFixture.user_opts()}
  end

  defp create_account_request_id(user_opts) do
    StarkInfra.IndividualAccountRequest.create!(
      [RequestFixture.generate_example_individual_account_request()],
      user_opts
    )
    |> hd
    |> Map.fetch!(:id)
  end

  @tag :individual_account_attachment
  test "create individual account attachment", %{user_opts: user_opts} do
    account_request_id = create_account_request_id(user_opts)

    {:ok, attachments} = StarkInfra.IndividualAccountAttachment.create(
      [Fixture.generate_example_individual_account_attachment(account_request_id)],
      user_opts
    )

    attachment = attachments |> hd
    assert !is_nil(attachment.id)
    assert !is_nil(attachment.status)
  end

  @tag :individual_account_attachment
  test "create! individual account attachment", %{user_opts: user_opts} do
    account_request_id = create_account_request_id(user_opts)

    attachment = StarkInfra.IndividualAccountAttachment.create!(
      [Fixture.generate_example_individual_account_attachment(account_request_id)],
      user_opts
    ) |> hd

    assert !is_nil(attachment.id)
  end

  @tag :individual_account_attachment
  test "get individual account attachment", %{user_opts: user_opts} do
    account_request_id = create_account_request_id(user_opts)

    created = StarkInfra.IndividualAccountAttachment.create!(
      [Fixture.generate_example_individual_account_attachment(account_request_id)],
      user_opts
    ) |> hd

    {:ok, retrieved} = StarkInfra.IndividualAccountAttachment.get(created.id, user_opts)

    assert retrieved.id == created.id
  end

  @tag :individual_account_attachment
  test "get! individual account attachment", %{user_opts: user_opts} do
    account_request_id = create_account_request_id(user_opts)

    created = StarkInfra.IndividualAccountAttachment.create!(
      [Fixture.generate_example_individual_account_attachment(account_request_id)],
      user_opts
    ) |> hd

    retrieved = StarkInfra.IndividualAccountAttachment.get!(created.id, user_opts)

    assert retrieved.id == created.id
  end

  @tag :individual_account_attachment
  test "query individual account attachment", %{user_opts: user_opts} do
    StarkInfra.IndividualAccountAttachment.query!([limit: 101, before: DateTime.utc_now()] ++ user_opts)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_account_attachment
  test "query! individual account attachment", %{user_opts: user_opts} do
    StarkInfra.IndividualAccountAttachment.query!([limit: 101, before: DateTime.utc_now()] ++ user_opts)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_account_attachment
  test "page individual account attachment", %{user_opts: user_opts} do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IndividualAccountAttachment.page/1, 2, [limit: 5] ++ user_opts)
    assert length(ids) <= 10
  end

  @tag :individual_account_attachment
  test "page! individual account attachment", %{user_opts: user_opts} do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IndividualAccountAttachment.page!/1, 2, [limit: 5] ++ user_opts)
    assert length(ids) <= 10
  end

  @tag :individual_account_attachment
  test "cancel individual account attachment", %{user_opts: user_opts} do
    account_request_id = create_account_request_id(user_opts)

    created = StarkInfra.IndividualAccountAttachment.create!(
      [Fixture.generate_example_individual_account_attachment(account_request_id)],
      user_opts
    ) |> hd

    {:ok, canceled} = StarkInfra.IndividualAccountAttachment.cancel(created.id, user_opts)

    assert canceled.id == created.id
    assert canceled.status == "deleted"
  end

  @tag :individual_account_attachment
  test "cancel! individual account attachment", %{user_opts: user_opts} do
    account_request_id = create_account_request_id(user_opts)

    created = StarkInfra.IndividualAccountAttachment.create!(
      [Fixture.generate_example_individual_account_attachment(account_request_id)],
      user_opts
    ) |> hd

    canceled = StarkInfra.IndividualAccountAttachment.cancel!(created.id, user_opts)

    assert canceled.id == created.id
    assert canceled.status == "deleted"
  end
end
