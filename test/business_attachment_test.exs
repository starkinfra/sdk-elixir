defmodule StarkInfraTest.BusinessAttachment do
  use ExUnit.Case

  defp business_identity_id do
    StarkInfra.BusinessIdentity.create!([
      StarkInfraTest.Utils.BusinessIdentity.generate_example_business_identity()
    ])
    |> hd
    |> Map.fetch!(:id)
  end

  @tag :business_attachment
  test "create business attachment" do
    {:ok, attachments} =
      StarkInfra.BusinessAttachment.create([
        StarkInfraTest.Utils.BusinessAttachment.generate_example_business_attachment(business_identity_id())
      ])

    attachment = attachments |> hd
    assert !is_nil(attachment.id)
  end

  @tag :business_attachment
  test "create! business attachment" do
    attachment =
      StarkInfra.BusinessAttachment.create!([
        StarkInfraTest.Utils.BusinessAttachment.generate_example_business_attachment(business_identity_id())
      ])
      |> hd

    assert !is_nil(attachment.id)
  end

  @tag :business_attachment
  test "get a business attachment" do
    created =
      StarkInfra.BusinessAttachment.create!([
        StarkInfraTest.Utils.BusinessAttachment.generate_example_business_attachment(business_identity_id())
      ])
      |> hd

    {:ok, attachment} = StarkInfra.BusinessAttachment.get(created.id, expand: ["content"])
    assert attachment.id == created.id
  end

  @tag :business_attachment
  test "get! a business attachment" do
    created =
      StarkInfra.BusinessAttachment.create!([
        StarkInfraTest.Utils.BusinessAttachment.generate_example_business_attachment(business_identity_id())
      ])
      |> hd

    attachment = StarkInfra.BusinessAttachment.get!(created.id, expand: ["content"])
    assert attachment.id == created.id
  end

  @tag :business_attachment
  test "query business attachments" do
    StarkInfra.BusinessAttachment.query!(limit: 1)
    |> Enum.take(1)
    |> (fn list -> assert length(list) <= 1 end).()
  end

  @tag :business_attachment
  test "query! business attachments" do
    StarkInfra.BusinessAttachment.query!(limit: 1)
    |> Enum.take(1)
    |> (fn list -> assert length(list) <= 1 end).()
  end

  @tag :business_attachment
  test "page business attachments" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.BusinessAttachment.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :business_attachment
  test "page! business attachments" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.BusinessAttachment.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :business_attachment
  test "cancel a business attachment" do
    created =
      StarkInfra.BusinessAttachment.create!([
        StarkInfraTest.Utils.BusinessAttachment.generate_example_business_attachment(business_identity_id())
      ])
      |> hd

    {:ok, attachment} = StarkInfra.BusinessAttachment.cancel(created.id)
    assert attachment.id == created.id
  end

  @tag :business_attachment
  test "cancel! a business attachment" do
    created =
      StarkInfra.BusinessAttachment.create!([
        StarkInfraTest.Utils.BusinessAttachment.generate_example_business_attachment(business_identity_id())
      ])
      |> hd

    attachment = StarkInfra.BusinessAttachment.cancel!(created.id)
    assert attachment.id == created.id
  end
end
