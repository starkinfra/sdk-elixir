defmodule StarkInfraTest.IssuingEmbossingKit do
  use ExUnit.Case

  @tag :issuing_embossing_kit
  test "get issuing embossing kit" do
    kit =
      StarkInfra.IssuingEmbossingKit.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, _kit} = StarkInfra.IssuingEmbossingKit.get(kit.id)
  end

  @tag :issuing_embossing_kit
  test "get! issuing embossing kit" do
    kit =
      StarkInfra.IssuingEmbossingKit.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    _kit = StarkInfra.IssuingEmbossingKit.get!(kit.id)
  end

  @tag :issuing_embossing_kit
  test "query issuing embossing kit" do
    StarkInfra.IssuingEmbossingKit.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :issuing_embossing_kit
  test "query! issuing embossing kit" do
    StarkInfra.IssuingEmbossingKit.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :issuing_embossing_kit
  test "query! issuing embossing kit with filters" do
    StarkInfra.IssuingEmbossingKit.query!(limit: 1)
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :issuing_embossing_kit
  test "page issuing embossing kit" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingEmbossingKit.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_embossing_kit
  test "page! issuing embossing kit" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingEmbossingKit.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
