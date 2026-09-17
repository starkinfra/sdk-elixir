defmodule StarkInfraTest.IssuingEmbossingKit do
  use ExUnit.Case

  @tag :issuing_embossing_kit
  test "query issuing embossing kit" do
    StarkInfra.IssuingEmbossingKit.query(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_embossing_kit
  test "query! issuing embossing kit" do
    StarkInfra.IssuingEmbossingKit.query!(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_embossing_kit
  test "get issuing embossing kit" do
    StarkInfra.IssuingEmbossingKit.query!(limit: 1)
    |> Enum.take(1)
    |> Enum.each(fn kit ->
      {:ok, retrieved_kit} = StarkInfra.IssuingEmbossingKit.get(kit.id)
      assert kit.id == retrieved_kit.id
    end)
  end

  @tag :issuing_embossing_kit
  test "get! issuing embossing kit" do
    StarkInfra.IssuingEmbossingKit.query!(limit: 1)
    |> Enum.take(1)
    |> Enum.each(fn kit ->
      assert kit.id == StarkInfra.IssuingEmbossingKit.get!(kit.id).id
    end)
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
