defmodule StarkInfraTest.IssuingDesign do
  use ExUnit.Case

  @tag :issuing_design
  test "query issuing design" do
    StarkInfra.IssuingDesign.query(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_design
  test "query! issuing design" do
    StarkInfra.IssuingDesign.query!(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_design
  test "get issuing design" do
    StarkInfra.IssuingDesign.query!(limit: 1)
    |> Enum.take(1)
    |> Enum.each(fn design ->
      {:ok, retrieved_design} = StarkInfra.IssuingDesign.get(design.id)
      assert design.id == retrieved_design.id
    end)
  end

  @tag :issuing_design
  test "get! issuing design" do
    StarkInfra.IssuingDesign.query!(limit: 1)
    |> Enum.take(1)
    |> Enum.each(fn design ->
      assert design.id == StarkInfra.IssuingDesign.get!(design.id).id
    end)
  end

  @tag :issuing_design
  test "page issuing design" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingDesign.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_design
  test "page! issuing design" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingDesign.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_design
  test "get issuing design pdf" do
    design =
      StarkInfra.IssuingDesign.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, pdf} = StarkInfra.IssuingDesign.pdf(design.id)

    file = File.open!("./issuing_design.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)

    assert byte_size(pdf) > 0
  end

  @tag :issuing_design
  test "get! issuing design pdf" do
    design =
      StarkInfra.IssuingDesign.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    pdf = StarkInfra.IssuingDesign.pdf!(design.id)

    file = File.open!("./issuing_design1.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)

    assert byte_size(pdf) > 0
  end
end
