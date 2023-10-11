defmodule StarkInfraTest.IndividualIdentity do
  use ExUnit.Case

  @tag :individual_identity
  test "create individual document" do
    {:ok, individual_identities} = StarkInfra.IndividualIdentity.create([example_individual_identity()])
    individual_identity = individual_identities |> hd
    assert !is_nil(individual_identity.id)
  end

  @tag :individual_identity
  test "create! individual document" do
    individual_identity = StarkInfra.IndividualIdentity.create!([example_individual_identity()]) |> hd
    assert !is_nil(individual_identity.id)
  end

  @tag :individual_identity
  test "get individual document" do
    individual_identity =
      StarkInfra.IndividualIdentity.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, identity} = StarkInfra.IndividualIdentity.get(individual_identity.id)

    assert !is_nil(identity.id)
  end

  @tag :individual_identity
  test "get! individual document" do
    individual_identity =
      StarkInfra.IndividualIdentity.query!(limit: 1)
      |> Enum.take(1)
      |> hd()
    identity = StarkInfra.IndividualIdentity.get!(individual_identity.id)

    assert !is_nil(identity.id)
  end

  @tag :individual_identity
  test "query individual document" do
    StarkInfra.IndividualIdentity.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_identity
  test "query! individual document" do
    StarkInfra.IndividualIdentity.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_identity
  test "page individual document" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IndividualIdentity.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :individual_identity
  test "page! individual document" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IndividualIdentity.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :individual_identity
  test "create and cancel individual document" do
    individual_identity = StarkInfra.IndividualIdentity.create!([example_individual_identity()]) |> hd

    assert !is_nil(individual_identity)

    {:ok, identity} = StarkInfra.IndividualIdentity.cancel(individual_identity.id)
    assert !is_nil(identity.id)
  end

  @tag :individual_identity
  test "create and cancel! individual document" do
    individual_identity = StarkInfra.IndividualIdentity.create!([example_individual_identity()]) |> hd

    assert !is_nil(individual_identity)

    identity = StarkInfra.IndividualIdentity.cancel!(individual_identity.id)
    assert !is_nil(identity.id)
  end

  def example_individual_identity() do
    %StarkInfra.IndividualIdentity{
      name: "Walter White",
      tax_id: "012.345.678-90",
      tags: ["breaking", "bad"]
    }
  end
end
