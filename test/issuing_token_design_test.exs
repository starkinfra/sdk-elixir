defmodule StarkInfraTest.IssuingTokenDesign do
  use ExUnit.Case

  @tag :issuing_token_design
  test "query issuing token design test" do
    designs = StarkInfra.IssuingTokenDesign.query(limit: 10) |> Enum.take(10)
    assert is_list(designs)
  end

  @tag :issuing_token_design
  test "query! issuing token design test" do
    designs = StarkInfra.IssuingTokenDesign.query!(limit: 10) |> Enum.take(10)
    assert is_list(designs)
  end

  @tag :issuing_token_design
  test "page issuing token design test" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingTokenDesign.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_token_design
  test "page! issuing token design test" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingTokenDesign.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_token_design
  test "get issuing token design test" do
    designs = StarkInfra.IssuingTokenDesign.query!(limit: 1) |> Enum.take(1)
    assert designs != [], "no IssuingTokenDesign in sandbox"
    design = designs |> hd

    {:ok, fetched} = StarkInfra.IssuingTokenDesign.get(design.id)
    assert fetched.id == design.id
  end

  @tag :issuing_token_design
  test "get! issuing token design test" do
    designs = StarkInfra.IssuingTokenDesign.query!(limit: 1) |> Enum.take(1)
    assert designs != [], "no IssuingTokenDesign in sandbox"
    design = designs |> hd

    fetched = StarkInfra.IssuingTokenDesign.get!(design.id)
    assert fetched.id == design.id
  end

  @tag :issuing_token_design
  test "pdf issuing token design test" do
    designs = StarkInfra.IssuingTokenDesign.query!(limit: 1) |> Enum.take(1)
    assert designs != [], "no IssuingTokenDesign in sandbox"
    design = designs |> hd

    {:ok, pdf} = StarkInfra.IssuingTokenDesign.pdf(design.id)
    assert byte_size(pdf) > 1000
  end

  @tag :issuing_token_design
  test "pdf! issuing token design test" do
    designs = StarkInfra.IssuingTokenDesign.query!(limit: 1) |> Enum.take(1)
    assert designs != [], "no IssuingTokenDesign in sandbox"
    design = designs |> hd

    pdf = StarkInfra.IssuingTokenDesign.pdf!(design.id)
    assert byte_size(pdf) > 1000
  end
end
