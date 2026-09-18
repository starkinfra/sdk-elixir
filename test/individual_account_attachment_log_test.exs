defmodule StarkInfraTest.IndividualAccountAttachment.Log do
  use ExUnit.Case

  alias StarkInfraTest.Utils.IndividualAccountRequest, as: RequestFixture
  alias StarkInfraTest.Utils.IndividualAccountAttachment, as: Fixture

  setup_all do
    {:ok, user_opts: RequestFixture.user_opts()}
  end

  defp create_attachment(user_opts) do
    account_request_id =
      StarkInfra.IndividualAccountRequest.create!(
        [RequestFixture.generate_example_individual_account_request()],
        user_opts
      )
      |> hd
      |> Map.fetch!(:id)

    StarkInfra.IndividualAccountAttachment.create!(
      [Fixture.generate_example_individual_account_attachment(account_request_id)],
      user_opts
    )
    |> hd
  end

  @tag :individual_account_attachment_log
  test "query individual account attachment log", %{user_opts: user_opts} do
    create_attachment(user_opts)

    StarkInfra.IndividualAccountAttachment.Log.query([limit: 101] ++ user_opts)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_account_attachment_log
  test "query! individual account attachment log", %{user_opts: user_opts} do
    create_attachment(user_opts)

    StarkInfra.IndividualAccountAttachment.Log.query!([limit: 101] ++ user_opts)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_account_attachment_log
  test "page individual account attachment log", %{user_opts: user_opts} do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IndividualAccountAttachment.Log.page/1, 2, [limit: 5] ++ user_opts)
    assert length(ids) <= 10
  end

  @tag :individual_account_attachment_log
  test "page! individual account attachment log", %{user_opts: user_opts} do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IndividualAccountAttachment.Log.page!/1, 2, [limit: 5] ++ user_opts)
    assert length(ids) <= 10
  end

  @tag :individual_account_attachment_log
  test "get individual account attachment log", %{user_opts: user_opts} do
    create_attachment(user_opts)

    log =
      StarkInfra.IndividualAccountAttachment.Log.query!([limit: 1] ++ user_opts)
      |> Enum.take(1)

    assert log != [], "no IndividualAccountAttachment log in sandbox"
    log = log |> hd()

    {:ok, unique_log} = StarkInfra.IndividualAccountAttachment.Log.get(log.id, user_opts)
    assert unique_log.id == log.id
    assert unique_log.attachment.id == log.attachment.id
  end

  @tag :individual_account_attachment_log
  test "get! individual account attachment log", %{user_opts: user_opts} do
    create_attachment(user_opts)

    log =
      StarkInfra.IndividualAccountAttachment.Log.query!([limit: 1] ++ user_opts)
      |> Enum.take(1)

    assert log != [], "no IndividualAccountAttachment log in sandbox"
    log = log |> hd()

    unique_log = StarkInfra.IndividualAccountAttachment.Log.get!(log.id, user_opts)
    assert unique_log.id == log.id
  end
end
