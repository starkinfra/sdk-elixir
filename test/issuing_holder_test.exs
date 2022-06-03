defmodule StarkInfraTest.IssuingHolder do
  use ExUnit.Case

  @tag :issuing_holder
  test "create issuing holder test" do
    {:ok, issuing_holder} = StarkInfra.IssuingHolder.create([StarkInfraTest.Utils.IssuingHolder.example_issuing_holder()])
    issuing_holder = issuing_holder |> Enum.take(1) |> hd

    {:ok, holder} = StarkInfra.IssuingHolder.get(issuing_holder.id)

    assert !is_nil(holder.id)
  end

  @tag :issuing_holder
  test "create! issuing holder test" do
    issuing_holder = StarkInfra.IssuingHolder.create!([StarkInfraTest.Utils.IssuingHolder.example_issuing_holder()])
    issuing_holder = issuing_holder |> Enum.take(1) |> hd

    {:ok, holder} = StarkInfra.IssuingHolder.get(issuing_holder.id)

    assert !is_nil(holder.id)
  end

  @tag :issuing_holder
  test "get issuing holder test" do
    holders = StarkInfra.IssuingHolder.query!(limit: 5)
    Enum.each(holders, fn holder ->
      {:ok, issuing_holder} = StarkInfra.IssuingHolder.get(holder.id)
      assert holder.id == issuing_holder.id
    end)
  end

  @tag :issuing_holder
  test "get! issuing holder test" do
    holders = StarkInfra.IssuingHolder.query!(limit: 5)
    Enum.each(holders, fn holder ->
      issuing_holder = StarkInfra.IssuingHolder.get!(holder.id)
      assert holder.id == issuing_holder.id
    end)
  end

  @tag :issuing_holder
  test "query issuing holder test" do
    holders = StarkInfra.IssuingHolder.query(limit: 10) |> Enum.take(10)

    assert length(holders) <= 10
  end

  @tag :issuing_holder
  test "query! issuing holder test" do
    issuing_holder = StarkInfra.IssuingHolder.query!(limit: 10)
      |> Enum.take(10)

    assert length(issuing_holder) <= 10
  end

  @tag :issuing_holder
  test "page issuing holder test" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingHolder.page/1, 2, limit: 5)

    assert length(ids) <= 10
  end

  @tag :issuing_holder
  test "page! issuing holder test" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingHolder.page!/1, 2, limit: 5)

    assert length(ids) <= 10
  end

  @tag :issuing_holder
  test "update issuing holder test" do
    {:ok, issuing_holder} = StarkInfra.IssuingHolder.create([StarkInfraTest.Utils.IssuingHolder.example_issuing_holder()])
    issuing_holder = issuing_holder |> Enum.take(1) |> hd

    {:ok, updated_issuing_holder} = StarkInfra.IssuingHolder.update(issuing_holder.id, %{name: "Updated Name"})

    assert updated_issuing_holder.name == "Updated Name"
  end

  @tag :issuing_holder
  test "update! issuing holder test" do
    {:ok, issuing_holder} = StarkInfra.IssuingHolder.create([StarkInfraTest.Utils.IssuingHolder.example_issuing_holder()])
    issuing_holder = issuing_holder |> Enum.take(1) |> hd

    updated_issuing_holder = StarkInfra.IssuingHolder.update!(issuing_holder.id, %{name: "Updated Name"})

    assert updated_issuing_holder.name == "Updated Name"
  end

  @tag :issuing_holder
  test "cancel issuing holder test" do
    issuing_holder = StarkInfra.IssuingHolder.create!([StarkInfraTest.Utils.IssuingHolder.example_issuing_holder()]) |> Enum.take(1) |> hd

    {:ok, canceled_issuing_holder} = StarkInfra.IssuingHolder.cancel(issuing_holder.id)

    assert canceled_issuing_holder.id == issuing_holder.id
  end

  @tag :issuing_holder
  test "cancel! issuing holder test" do
    issuing_holder = StarkInfra.IssuingHolder.create!([StarkInfraTest.Utils.IssuingHolder.example_issuing_holder()]) |> Enum.take(1) |> hd
    canceled_issuing_holder = StarkInfra.IssuingHolder.cancel!(issuing_holder.id)

    assert canceled_issuing_holder.id == issuing_holder.id
  end

end
