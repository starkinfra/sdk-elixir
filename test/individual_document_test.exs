defmodule StarkInfraTest.IndividualDocument do
  use ExUnit.Case
  alias File

  @tag :individual_document
  test "create individual document front" do
    {:ok, documents} = StarkInfra.IndividualDocument.create([example_individual_document_front()])
    document = documents |> hd
    assert !is_nil(document.id)
  end

  @tag :individual_document
  test "create! individual document front" do
    document = StarkInfra.IndividualDocument.create!([example_individual_document_front()]) |> hd
    assert !is_nil(document.id)
  end

  @tag :individual_document
  test "create individual document back" do
    {:ok, documents} = StarkInfra.IndividualDocument.create([example_individual_document_back()])
    document = documents |> hd
    assert !is_nil(document.id)
  end

  @tag :individual_document
  test "create! individual document back" do
    document = StarkInfra.IndividualDocument.create!([example_individual_document_back()]) |> hd
    assert !is_nil(document.id)
  end

  @tag :individual_document
  test "create individual selfie" do
    {:ok, documents} = StarkInfra.IndividualDocument.create([example_individual_document_selfie()])
    document = documents |> hd
    assert !is_nil(document.id)
  end

  @tag :individual_document
  test "create! individual selfie" do
    document = StarkInfra.IndividualDocument.create!([example_individual_document_selfie()]) |> hd
    assert !is_nil(document.id)
  end

  @tag :individual_document
  test "get individual document" do
    individual_document =StarkInfra.IndividualDocument.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, document} = StarkInfra.IndividualDocument.get(individual_document.id)

    assert !is_nil(document.id)
  end

  @tag :individual_document
  test "get! individual document" do
    individual_document =
      StarkInfra.IndividualDocument.query!(limit: 1)
      |> Enum.take(1)
      |> hd()
    document = StarkInfra.IndividualDocument.get!(individual_document.id)

    assert !is_nil(document.id)
  end

  @tag :individual_document
  test "query individual document" do
    StarkInfra.IndividualDocument.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_document
  test "query! individual document" do
    StarkInfra.IndividualDocument.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :individual_document
  test "page individual document" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IndividualDocument.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :individual_document
  test "page! individual document" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IndividualDocument.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  def example_individual_document_front() do
    {:ok, data} = File.read("./test/utils/identity/identity-front-face.png")
    %StarkInfra.IndividualDocument{
      type: "identity-front",
      content: data,
      content_type: "image/png",
      identity_id: "5732110983757824",
      tags: ["breaking", "bad"]
    }
  end
  def example_individual_document_back() do
    {:ok, data} = File.read("./test/utils/identity/identity-back-face.png")
    %StarkInfra.IndividualDocument{
      type: "identity-back",
      content: data,
      content_type: "image/png",
      identity_id: "5732110983757824",
      tags: ["breaking", "bad"]
    }
  end
  def example_individual_document_selfie() do
    {:ok, data} = File.read("./test/utils/identity/walter-white.png")
    %StarkInfra.IndividualDocument{
      type: "selfie",
      content: data,
      content_type: "image/png",
      identity_id: "5732110983757824",
      tags: ["breaking", "bad"]
    }
  end
end
