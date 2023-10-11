defmodule StarkInfraTest.IssuingDesign do
  use ExUnit.Case

  @tag :issuing_design
  test "get issuing_design" do
    design =
      StarkInfra.IssuingDesign.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, _design} = StarkInfra.IssuingDesign.get(design.id)
  end

  @tag :issuing_design
  test "get! issuing_design" do
    design =
      StarkInfra.IssuingDesign.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    _design = StarkInfra.IssuingDesign.get!(design.id)
  end

  @tag :issuing_design
  test "query issuing_design" do
    StarkInfra.IssuingDesign.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :issuing_design
  test "query! issuing_design" do
    StarkInfra.IssuingDesign.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :issuing_design
  test "query! issuing_design with filters" do
    StarkInfra.IssuingDesign.query!(limit: 1)
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :issuing_design
  test "page issuing_design" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingDesign.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_design
  test "page! issuing_design" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingDesign.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
