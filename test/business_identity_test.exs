defmodule StarkInfraTest.BusinessIdentity do
  use ExUnit.Case

  @tag :business_identity
  test "create business identity" do
    {:ok, identities} =
      StarkInfra.BusinessIdentity.create([
        StarkInfraTest.Utils.BusinessIdentity.generate_example_business_identity()
      ])

    identity = identities |> hd
    assert !is_nil(identity.id)
  end

  @tag :business_identity
  test "create! business identity" do
    identity =
      StarkInfra.BusinessIdentity.create!([
        StarkInfraTest.Utils.BusinessIdentity.generate_example_business_identity()
      ])
      |> hd

    assert !is_nil(identity.id)
  end

  @tag :business_identity
  test "get a business identity" do
    created =
      StarkInfra.BusinessIdentity.create!([
        StarkInfraTest.Utils.BusinessIdentity.generate_example_business_identity()
      ])
      |> hd

    {:ok, identity} = StarkInfra.BusinessIdentity.get(created.id)
    assert identity.id == created.id
  end

  @tag :business_identity
  test "get! a business identity" do
    created =
      StarkInfra.BusinessIdentity.create!([
        StarkInfraTest.Utils.BusinessIdentity.generate_example_business_identity()
      ])
      |> hd

    identity = StarkInfra.BusinessIdentity.get!(created.id)
    assert identity.id == created.id
  end

  @tag :business_identity
  test "query business identities" do
    StarkInfra.BusinessIdentity.query!(limit: 1)
    |> Enum.take(1)
    |> (fn list -> assert length(list) <= 1 end).()
  end

  @tag :business_identity
  test "query! business identities" do
    StarkInfra.BusinessIdentity.query!(limit: 1)
    |> Enum.take(1)
    |> (fn list -> assert length(list) <= 1 end).()
  end

  @tag :business_identity
  test "page business identities" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.BusinessIdentity.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :business_identity
  test "page! business identities" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.BusinessIdentity.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :business_identity
  test "update a business identity" do
    created =
      StarkInfra.BusinessIdentity.create!([
        StarkInfraTest.Utils.BusinessIdentity.generate_example_business_identity()
      ])
      |> hd

    {:ok, identity} = StarkInfra.BusinessIdentity.update(created.id, tags: ["onboarding-123-updated"])
    assert identity.id == created.id
  end

  @tag :business_identity
  test "update! a business identity" do
    created =
      StarkInfra.BusinessIdentity.create!([
        StarkInfraTest.Utils.BusinessIdentity.generate_example_business_identity()
      ])
      |> hd

    identity = StarkInfra.BusinessIdentity.update!(created.id, tags: ["onboarding-123-updated"])
    assert identity.id == created.id
  end

  @tag :business_identity
  test "cancel a business identity" do
    created =
      StarkInfra.BusinessIdentity.create!([
        StarkInfraTest.Utils.BusinessIdentity.generate_example_business_identity()
      ])
      |> hd

    {:ok, identity} = StarkInfra.BusinessIdentity.cancel(created.id)
    assert identity.id == created.id
  end

  @tag :business_identity
  test "cancel! a business identity" do
    created =
      StarkInfra.BusinessIdentity.create!([
        StarkInfraTest.Utils.BusinessIdentity.generate_example_business_identity()
      ])
      |> hd

    identity = StarkInfra.BusinessIdentity.cancel!(created.id)
    assert identity.id == created.id
  end
end
