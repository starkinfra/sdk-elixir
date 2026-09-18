defmodule StarkInfraTest.IndividualIdentity do
  use ExUnit.Case

  alias StarkInfraTest.Utils.IndividualIdentity, as: Fixture

  # IndividualIdentity is known to lack permission on the shared sandbox project.
  # These tests run for real and are left to fail honestly when that happens;
  # see the lane report for the observed error class.

  @tag :individual_identity
  test "create individual identity" do
    {:ok, identities} = StarkInfra.IndividualIdentity.create([Fixture.generate_example_individual_identity()])
    identity = identities |> hd
    assert !is_nil(identity.id)
  end

  @tag :individual_identity
  test "create! individual identity" do
    identity = StarkInfra.IndividualIdentity.create!([Fixture.generate_example_individual_identity()]) |> hd
    assert !is_nil(identity.id)
  end

  @tag :individual_identity
  test "get individual identity" do
    created = StarkInfra.IndividualIdentity.create!([Fixture.generate_example_individual_identity()]) |> hd

    {:ok, retrieved} = StarkInfra.IndividualIdentity.get(created.id)

    assert retrieved.id == created.id
  end

  @tag :individual_identity
  test "get! individual identity" do
    created = StarkInfra.IndividualIdentity.create!([Fixture.generate_example_individual_identity()]) |> hd

    retrieved = StarkInfra.IndividualIdentity.get!(created.id)

    assert retrieved.id == created.id
  end

  @tag :individual_identity
  test "query individual identity" do
    StarkInfra.IndividualIdentity.query!(limit: 101, before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_identity
  test "query! individual identity" do
    StarkInfra.IndividualIdentity.query!(limit: 101, before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_identity
  test "page individual identity" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IndividualIdentity.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :individual_identity
  test "page! individual identity" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IndividualIdentity.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :individual_identity
  test "update individual identity tax_id" do
    created = StarkInfra.IndividualIdentity.create!([Fixture.generate_example_individual_identity()]) |> hd

    {:ok, updated} = StarkInfra.IndividualIdentity.update(created.id, tax_id: "012.345.678-90")

    assert updated.id == created.id
  end

  @tag :individual_identity
  test "update! individual identity tax_id" do
    created = StarkInfra.IndividualIdentity.create!([Fixture.generate_example_individual_identity()]) |> hd

    updated = StarkInfra.IndividualIdentity.update!(created.id, tax_id: "012.345.678-90")

    assert updated.id == created.id
  end

  @tag :individual_identity
  test "cancel individual identity" do
    created = StarkInfra.IndividualIdentity.create!([Fixture.generate_example_individual_identity()]) |> hd

    {:ok, canceled} = StarkInfra.IndividualIdentity.cancel(created.id)

    assert canceled.id == created.id
  end

  @tag :individual_identity
  test "cancel! individual identity" do
    created = StarkInfra.IndividualIdentity.create!([Fixture.generate_example_individual_identity()]) |> hd

    canceled = StarkInfra.IndividualIdentity.cancel!(created.id)

    assert canceled.id == created.id
  end
end
