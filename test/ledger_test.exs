defmodule StarkInfraTest.Ledger do
  use ExUnit.Case

  @tag :ledger
  test "create ledger" do
    {:ok, ledgers} = StarkInfra.Ledger.create([StarkInfraTest.Utils.Ledger.example_ledger()])
    ledger = ledgers |> hd
    assert !is_nil(ledger.id)
  end

  @tag :ledger
  test "create! ledger" do
    ledger = StarkInfra.Ledger.create!([StarkInfraTest.Utils.Ledger.example_ledger()]) |> hd
    assert !is_nil(ledger.id)
  end

  @tag :ledger
  test "get ledger" do
    StarkInfra.Ledger.query!(limit: 5)
      |> Enum.map(fn(ledger) ->
        {:ok, retrieved_ledger} = StarkInfra.Ledger.get(ledger.id)
        assert ledger.id == retrieved_ledger.id
      end)
  end

  @tag :ledger
  test "get! ledger" do
    StarkInfra.Ledger.query!(limit: 8)
      |> Enum.map(fn(ledger) ->
        assert ledger.id == StarkInfra.Ledger.get!(ledger.id).id
      end)
  end

  @tag :ledger
  test "query ledger" do
    ledgers = StarkInfra.Ledger.query!(limit: 5)
      |> Enum.map(fn(ledger) ->
        assert ledger.id == StarkInfra.Ledger.get!(ledger.id).id
      end)
    assert length(ledgers) <= 5
  end

  @tag :ledger
  test "query! ledger" do
    ledgers = StarkInfra.Ledger.query!(limit: 5)
      |> Enum.map(fn(ledger) ->
        assert ledger.id == StarkInfra.Ledger.get!(ledger.id).id
      end)
    assert length(ledgers) <= 5
  end

  @tag :ledger
  test "page ledger" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.Ledger.page/1, 2, limit: 5)
    assert length(ids) <= 10

    Enum.map(ids, fn(id) ->
      assert id == StarkInfra.Ledger.get!(id).id
    end)
  end

  @tag :ledger
  test "page! ledger" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.Ledger.page!/1, 2, limit: 5)
    assert length(ids) <= 10

    Enum.map(ids, fn(id) ->
      assert id == StarkInfra.Ledger.get!(id).id
    end)
  end

  @tag :ledger
  test "update ledger" do
    {:ok, ledgers} = StarkInfra.Ledger.create([StarkInfraTest.Utils.Ledger.example_ledger()])
    ledger = ledgers |> hd

    {:ok, updated_ledger} = StarkInfra.Ledger.update(
      ledger.id,
      tags: ["updated"]
    )

    assert updated_ledger.id == ledger.id
    assert updated_ledger.tags == ["updated"]
  end

  @tag :ledger
  test "update! ledger" do
    ledger = StarkInfra.Ledger.create!([StarkInfraTest.Utils.Ledger.example_ledger()]) |> hd

    updated_ledger = StarkInfra.Ledger.update!(
      ledger.id,
      tags: ["updated"]
    )

    assert updated_ledger.id == ledger.id
    assert updated_ledger.tags == ["updated"]
  end
end
