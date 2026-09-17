defmodule StarkInfraTest.StaticBrcode do
  use ExUnit.Case

  @tag :static_brcode
  test "create static brcode" do
    {:ok, brcodes} = StarkInfra.StaticBrcode.create([StarkInfraTest.Utils.StaticBrcode.generate_example_static_brcode()])
    brcode = brcodes |> hd
    assert !is_nil(brcode.uuid)
  end

  @tag :static_brcode
  test "create! static brcode" do
    brcode = StarkInfra.StaticBrcode.create!([StarkInfraTest.Utils.StaticBrcode.generate_example_static_brcode()]) |> hd
    assert !is_nil(brcode.uuid)
  end

  @tag :static_brcode
  test "query static brcode" do
    StarkInfra.StaticBrcode.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :static_brcode
  test "query! static brcode" do
    StarkInfra.StaticBrcode.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  # StaticBrcode.id is the BR code payload text, not a unique key (two brcodes created
  # with the same parameters produce the same id): pages are deduplicated by uuid instead,
  # unlike StarkInfraTest.Utils.Page, which assumes entity.id is unique.
  @tag :static_brcode
  test "page static brcode" do
    uuids = collect_pages(
      fn options ->
        {:ok, page} = StarkInfra.StaticBrcode.page(options)
        page
      end,
      2,
      limit: 5
    )
    assert length(uuids) <= 10
  end

  @tag :static_brcode
  test "page! static brcode" do
    uuids = collect_pages(&StarkInfra.StaticBrcode.page!/1, 2, limit: 5)
    assert length(uuids) <= 10
  end

  defp collect_pages(page_fun, iterations, options) do
    collect_pages(page_fun, iterations, options, [])
  end

  defp collect_pages(_page_fun, 0, _options, uuids), do: uuids

  defp collect_pages(page_fun, iterations, options, uuids) do
    case page_fun.(options) do
      {_cursor, []} ->
        uuids

      {cursor, brcodes} ->
        new_uuids = Enum.map(brcodes, & &1.uuid)
        assert Enum.all?(new_uuids, fn uuid -> uuid not in uuids end)
        combined = uuids ++ new_uuids

        case cursor do
          nil -> combined
          _ -> collect_pages(page_fun, iterations - 1, Keyword.put(options, :cursor, cursor), combined)
        end
    end
  end

  @tag :static_brcode
  test "get static brcode" do
    brcode =
      StarkInfra.StaticBrcode.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, fetched} = StarkInfra.StaticBrcode.get(brcode.uuid)

    assert fetched.uuid == brcode.uuid
  end

  @tag :static_brcode
  test "get! static brcode" do
    brcode =
      StarkInfra.StaticBrcode.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    fetched = StarkInfra.StaticBrcode.get!(brcode.uuid)

    assert fetched.uuid == brcode.uuid
  end
end
