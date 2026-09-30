defmodule StarkInfraTest.AiKnowledgeBase do
  use ExUnit.Case

  @moduletag :ai_knowledge_base

  setup_all do
    {:ok, knowledge_base} = StarkInfra.AiKnowledgeBase.create(StarkInfraTest.Utils.AiKnowledgeBase.example_ai_knowledge_base())

    on_exit(fn -> delete_or_warn(knowledge_base.id) end)

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
    # the crawl moves the status on its own, so filter by the name and status the API reports right now
    current = StarkInfra.AiKnowledgeBase.get!(knowledge_base.id)
    found = StarkInfra.AiKnowledgeBase.query!(name: current.name, status: current.status) |> Enum.to_list()

    assert knowledge_base.id in Enum.map(found, fn entity -> entity.id end)
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
    {:error, [error | _]} = StarkInfra.AiKnowledgeBase.create(%StarkInfra.AiKnowledgeBase{name: "invalid", root_url: "not-a-url"})

    assert error.code == "invalidRootUrl"
  end

  test "get unknown id returns input errors" do
    {:error, [error | _]} = StarkInfra.AiKnowledgeBase.get("0000000000000000")

    assert error.code == "invalidKnowledgeBaseId"
  end

  # the sandbox answers 500 to delete for a valid id, which is handled here instead of swallowed
  defp delete_or_warn(id) do
    case StarkInfra.AiKnowledgeBase.delete([id]) do
      {:ok, _deleted} -> :ok
      {:error, [%StarkInfra.Error{code: "internalServerError"} | _]} ->
        IO.puts(:stderr, "AiKnowledgeBase #{id} was not deleted: the API answered 500")
      {:error, errors} -> raise StarkInfra.Utils.API.errors_to_string(errors)
    end
  end
end
