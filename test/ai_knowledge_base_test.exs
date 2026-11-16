defmodule StarkInfraTest.AiKnowledgeBase do
  use ExUnit.Case

  @moduletag :ai_knowledge_base

  setup_all do
    {:ok, knowledge_base} = StarkInfra.AiKnowledgeBase.create(StarkInfraTest.Utils.AiKnowledgeBase.example_ai_knowledge_base())

    on_exit(fn -> StarkInfra.AiKnowledgeBase.delete!([knowledge_base.id]) end)

    %{knowledge_base: knowledge_base}
  end

  test "create returns a processing knowledge base", %{knowledge_base: knowledge_base} do
    assert is_binary(knowledge_base.id)
    assert knowledge_base.status == "processing"
    assert knowledge_base.root_url == "https://docs.starkinfra.com"
    assert knowledge_base.is_recursive == false
    assert knowledge_base.tags == ["sdk-elixir", "test"]
    assert %DateTime{} = knowledge_base.created
  end

  test "get", %{knowledge_base: knowledge_base} do
    {:ok, fetched} = StarkInfra.AiKnowledgeBase.get(knowledge_base.id)

    assert fetched.id == knowledge_base.id
    assert fetched.root_url == knowledge_base.root_url
  end

  test "get!", %{knowledge_base: knowledge_base} do
    assert StarkInfra.AiKnowledgeBase.get!(knowledge_base.id).id == knowledge_base.id
  end

  test "query filters by ids", %{knowledge_base: knowledge_base} do
    found = StarkInfra.AiKnowledgeBase.query(ids: [knowledge_base.id]) |> Enum.to_list()

    assert Enum.map(found, fn {:ok, entity} -> entity.id end) == [knowledge_base.id]
  end

  test "query! filters by name and status", %{knowledge_base: knowledge_base} do
    current = StarkInfra.AiKnowledgeBase.get!(knowledge_base.id)
    found = StarkInfra.AiKnowledgeBase.query!(name: current.name, status: current.status) |> Enum.to_list()

    assert knowledge_base.id in Enum.map(found, fn entity -> entity.id end)
  end

  test "query with limit stops at the limit" do
    assert length(StarkInfra.AiKnowledgeBase.query!(limit: 1) |> Enum.to_list()) <= 1
  end

  test "page follows the cursor until it is nil", %{knowledge_base: knowledge_base} do
    found = StarkInfraTest.Utils.Ai.all_pages(&StarkInfra.AiKnowledgeBase.page/1, limit: 2)

    assert knowledge_base.id in Enum.map(found, & &1.id)
  end

  test "page filters by ids", %{knowledge_base: knowledge_base} do
    assert {:ok, {nil, [%StarkInfra.AiKnowledgeBase{id: id}]}} = StarkInfra.AiKnowledgeBase.page(ids: [knowledge_base.id])
    assert id == knowledge_base.id
  end

  test "page with limit 101 returns the API error" do
    assert {:error, [%StarkInfra.Error{code: "invalidLimit"} | _]} = StarkInfra.AiKnowledgeBase.page(limit: 101)
  end

  test "delete returns the deleted knowledge bases" do
    created = StarkInfra.AiKnowledgeBase.create!(StarkInfraTest.Utils.AiKnowledgeBase.example_ai_knowledge_base())

    assert {:ok, [%StarkInfra.AiKnowledgeBase{id: id}]} = StarkInfra.AiKnowledgeBase.delete([created.id])
    assert id == created.id
  end

  test "query without match is empty" do
    assert StarkInfra.AiKnowledgeBase.query!(name: "no-knowledge-base-has-this-name") |> Enum.to_list() == []
  end

  test "update changes name and tags only", %{knowledge_base: knowledge_base} do
    try do
      {:ok, updated} = StarkInfra.AiKnowledgeBase.update(knowledge_base.id, name: "renamed-by-sdk", tags: ["renamed"])

      assert updated.name == "renamed-by-sdk"
      assert updated.tags == ["renamed"]
      assert updated.root_url == knowledge_base.root_url
    after
      StarkInfra.AiKnowledgeBase.update!(knowledge_base.id, name: knowledge_base.name, tags: knowledge_base.tags)
    end
  end

  test "update! keeps false" , %{knowledge_base: knowledge_base} do
    assert StarkInfra.AiKnowledgeBase.update!(knowledge_base.id, is_recursive: true).is_recursive == true
    assert StarkInfra.AiKnowledgeBase.update!(knowledge_base.id, is_recursive: false).is_recursive == false
  end

  test "create with invalid root url returns input errors" do
    assert {:error, [%StarkInfra.Error{code: "invalidRootUrl"} | _]} = StarkInfra.AiKnowledgeBase.create(%StarkInfra.AiKnowledgeBase{name: "invalid", root_url: "not-a-url"})
  end

  test "get unknown id returns input errors" do
    assert {:error, [%StarkInfra.Error{code: "invalidKnowledgeBaseId"} | _]} = StarkInfra.AiKnowledgeBase.get("0000000000000000")
  end
end
