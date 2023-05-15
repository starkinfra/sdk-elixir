defmodule StarkInfraTest.PixInfraction do
  use ExUnit.Case

  @tag :pix_infraction
  test "create and cancel pix infraction" do
    {:ok, pix_infractions} = StarkInfra.PixInfraction.create([example_pix_infraction()])
    pix_infraction = pix_infractions |> hd
    {:ok, canceled_pix} = StarkInfra.PixInfraction.cancel(pix_infraction.id)
    assert !is_nil(canceled_pix.id)
  end

  @tag :pix_infraction
  test "create! and cancel pix infraction" do
    pix_infraction = StarkInfra.PixInfraction.create!([example_pix_infraction()]) |> hd
    canceled_pix = StarkInfra.PixInfraction.cancel!(pix_infraction.id)
    assert !is_nil(canceled_pix.id)
  end

  @tag :pix_infraction
  test "get pix infraction" do
    StarkInfra.PixInfraction.query!(limit: 5)
      |> Enum.map(fn(pix_infraction) ->
        {:ok, pix} = StarkInfra.PixInfraction.get(pix_infraction.id)
        assert pix_infraction.id == pix.id
      end)
  end

  @tag :pix_infraction
  test "get! pix infraction" do
    StarkInfra.PixInfraction.query!(limit: 8)
      |> Enum.map(fn(pix_infraction) ->
        assert pix_infraction.id == StarkInfra.PixInfraction.get!(pix_infraction.id).id
      end)
  end

  @tag :pix_infraction
  test "query pix infraction" do
    pix_infraction = StarkInfra.PixInfraction.query!(limit: 5)
      |> Enum.map(fn(pix_infraction) ->
        assert pix_infraction.id == StarkInfra.PixInfraction.get!(pix_infraction.id).id
      end)
    assert length(pix_infraction) <= 5
  end

  @tag :pix_infraction
  test "query! pix infraction" do
    pix_infraction = StarkInfra.PixInfraction.query!(limit: 5)
      |> Enum.map(fn(pix_infraction) ->
        assert pix_infraction.id == StarkInfra.PixInfraction.get!(pix_infraction.id).id
      end)
    assert length(pix_infraction) <= 5
  end

  @tag :pix_infraction
  test "page pix infraction" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixInfraction.page/1, 2, limit: 5)
    assert length(ids) <= 10

    Enum.map(ids, fn(id) ->
      assert id == StarkInfra.PixInfraction.get!(id).id
    end)
  end

  @tag :pix_infraction
  test "page! pix infraction" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixInfraction.page!/1, 2, limit: 5)
    assert length(ids) <= 10

    Enum.map(ids, fn(id) ->
      assert id == StarkInfra.PixInfraction.get!(id).id
    end)
  end

  @tag :pix_infraction
  test "update pix infraction" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixInfraction.page!/1, 3, limit: 2, status: "created")
    assert length(ids) <= 6

    Enum.map(ids, fn(id) ->
      result = Enum.take_random(["agreed", "disagreed"], 1) |> hd
      {:ok, updated_pix} = StarkInfra.PixInfraction.update(
        id,
        result
      )

    pix_infraction = StarkInfra.PixInfraction.get!(id)

    assert updated_pix.id == pix_infraction.id
    assert updated_pix.result == pix_infraction.result
    assert pix_infraction.result == result
    end)
  end

  @tag :pix_infraction
  test "update! pix infraction" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixInfraction.page!/1, 3, limit: 2, status: "created")
    assert length(ids) <= 6

      Enum.map(ids, fn(id) ->
        result = Enum.take_random(["agreed", "disagreed"], 1) |> hd
        updated_pix = StarkInfra.PixInfraction.update!(
          id,
          result
        )

      pix_infraction = StarkInfra.PixInfraction.get!(id)

      assert updated_pix.id == pix_infraction.id
      assert updated_pix.result == pix_infraction.result
      assert pix_infraction.result == result
    end)
  end

  def get_end_to_end_id_to_infraction(pix_request, cursor) when length(pix_request) == 0 do
    {cursor, requests} = StarkInfra.PixRequest.page!(limit: 10, cursor: cursor, status: ["success"])
    pix_in = Enum.filter(requests, fn(request) -> request.flow == "out" end)
      |> Enum.filter(fn(request) -> request.amount > 10000 end)
      |> Enum.take(1)

    get_end_to_end_id_to_infraction(pix_in, cursor)
  end

  def get_end_to_end_id_to_infraction(pix_request, _cursor) do
    pix_request
  end

  def example_pix_infraction() do
    pix = get_end_to_end_id_to_infraction([], nil) |> hd
    %StarkInfra.PixInfraction
      {reference_id: pix.end_to_end_id, type: "fraud"}
  end
end
