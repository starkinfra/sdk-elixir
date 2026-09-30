defmodule StarkInfraTest.AiKnowledgeBase.AtTheHttpBoundary do
  use ExUnit.Case

  @moduletag :ai_knowledge_base

  setup do
    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)
    {_module, original_binary, original_file} = :code.get_object_code(:httpc)
    :persistent_term.put(:ai_knowledge_base_test_pid, self())
    :persistent_term.put(:ai_knowledge_base_test_bodies, [])
    compile_fake_httpc()

    on_exit(fn ->
      :persistent_term.erase(:ai_knowledge_base_test_pid)
      :persistent_term.erase(:ai_knowledge_base_test_bodies)
      :code.purge(:httpc)
      :code.delete(:httpc)
      :code.purge(:httpc)
      {:module, :httpc} = :code.load_binary(:httpc, original_file, original_binary)
    end)

    :ok
  end

  @knowledge_base %{
    "id" => "6767676767676767",
    "name" => "Public Documentation",
    "rootUrl" => "https://docs.starkinfra.com",
    "isRecursive" => true,
    "status" => "success",
    "tags" => ["support"],
    "created" => "2022-01-01T00:00:00.000000+00:00",
    "updated" => "2022-01-02T00:00:00.000000+00:00"
  }

  test "hosts groups pages by host" do
    hosts = %{
      "docs.starkinfra.com" => [%{
        "originalUrl" => "https://docs.starkinfra.com/get-started",
        "status" => "success",
        "storageUrl" => "https://storage.googleapis.com/ai-knowledge/6767676767676767/get-started.md"
      }]
    }
    answer_with([%{"hosts" => hosts}])

    {:ok, result} = StarkInfra.AiKnowledgeBase.hosts("6767676767676767")

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-knowledge-base/6767676767676767/hosts")
    assert result == %{
      "docs.starkinfra.com" => [%{
        original_url: "https://docs.starkinfra.com/get-started",
        status: "success",
        storage_url: "https://storage.googleapis.com/ai-knowledge/6767676767676767/get-started.md"
      }]
    }
  end

  test "delete sends ids in the query string and returns the deleted objects" do
    answer_with([%{"knowledgeBases" => [@knowledge_base]}])

    {:ok, deleted} = StarkInfra.AiKnowledgeBase.delete(["6767676767676767", "6767676767676768"])

    assert_receive {:http, :delete, request, _http_options, _options}
    assert tuple_size(request) == 2
    assert to_string(elem(request, 0)) |> String.ends_with?("/v2/ai-knowledge-base?ids=6767676767676767%2C6767676767676768")
    assert [%StarkInfra.AiKnowledgeBase{id: "6767676767676767", name: "Public Documentation", root_url: "https://docs.starkinfra.com"}] = deleted
  end

  test "delete! returns the deleted objects" do
    answer_with([%{"knowledgeBases" => [@knowledge_base]}])

    assert [%StarkInfra.AiKnowledgeBase{id: "6767676767676767"}] = StarkInfra.AiKnowledgeBase.delete!(["6767676767676767"])
  end

  test "create reads the knowledgeBase key and leaves out the nil fields" do
    answer_with([%{"knowledgeBase" => @knowledge_base}])

    {:ok, created} = StarkInfra.AiKnowledgeBase.create(%StarkInfra.AiKnowledgeBase{name: "Public Documentation", root_url: "https://docs.starkinfra.com", tags: ["support"]})

    assert_receive {:http, :post, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-knowledge-base")
    assert body |> to_string() |> Jason.decode!() == %{"name" => "Public Documentation", "rootUrl" => "https://docs.starkinfra.com", "tags" => ["support"]}
    assert %StarkInfra.AiKnowledgeBase{id: "6767676767676767", status: "success"} = created
  end

  test "get reads the knowledgeBase key" do
    answer_with([%{"knowledgeBase" => @knowledge_base}])

    {:ok, fetched} = StarkInfra.AiKnowledgeBase.get("6767676767676767")

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-knowledge-base/6767676767676767")
    assert fetched.root_url == "https://docs.starkinfra.com"
  end

  test "update sends only the given fields, false included" do
    answer_with([%{"knowledgeBase" => @knowledge_base}])

    {:ok, _updated} = StarkInfra.AiKnowledgeBase.update("6767676767676767", is_recursive: false, tags: [])

    assert_receive {:http, :patch, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-knowledge-base/6767676767676767")
    assert body |> to_string() |> Jason.decode!() == %{"isRecursive" => false, "tags" => []}
  end

  test "query sends the ids comma-separated, name and status" do
    answer_with([%{"cursor" => nil, "knowledgeBases" => [@knowledge_base]}])

    [%StarkInfra.AiKnowledgeBase{id: "6767676767676767"}] = StarkInfra.AiKnowledgeBase.query!(ids: ["1", "2"], name: "docs", status: "success") |> Enum.to_list()

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert query_of(url) == %{"ids" => "1,2", "name" => "docs", "status" => "success"}
  end

  test "query follows the cursor through an empty page until it is nil" do
    answer_with([
      %{"cursor" => "second", "knowledgeBases" => [@knowledge_base]},
      %{"cursor" => "third", "knowledgeBases" => []},
      %{"cursor" => nil, "knowledgeBases" => [@knowledge_base]}
    ])

    found = StarkInfra.AiKnowledgeBase.query() |> Enum.to_list()

    assert [{:ok, %StarkInfra.AiKnowledgeBase{}}, {:ok, %StarkInfra.AiKnowledgeBase{}}] = found
    assert_receive {:http, :get, {first_url, _headers}, _http_options, _options}
    assert query_of(first_url) == %{}
    assert_receive {:http, :get, {second_url, _headers}, _http_options, _options}
    assert query_of(second_url) == %{"cursor" => "second"}
    assert_receive {:http, :get, {third_url, _headers}, _http_options, _options}
    assert query_of(third_url) == %{"cursor" => "third"}
    refute_received {:http, :get, _request, _http_options, _options}
  end

  test "query with limit 150 asks for 100 and then 50" do
    answer_with([
      %{"cursor" => "second", "knowledgeBases" => [@knowledge_base]},
      %{"cursor" => "third", "knowledgeBases" => [@knowledge_base]}
    ])

    StarkInfra.AiKnowledgeBase.query!(limit: 150) |> Enum.to_list()

    assert_receive {:http, :get, {first_url, _headers}, _http_options, _options}
    assert query_of(first_url) == %{"limit" => "100"}
    assert_receive {:http, :get, {second_url, _headers}, _http_options, _options}
    assert query_of(second_url) == %{"cursor" => "second", "limit" => "50"}
    refute_received {:http, :get, _request, _http_options, _options}
  end

  test "query stops at the limit even when the API still has a cursor" do
    answer_with([%{"cursor" => "second", "knowledgeBases" => [@knowledge_base]}])

    StarkInfra.AiKnowledgeBase.query!(limit: 100) |> Enum.to_list()

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert query_of(url) == %{"limit" => "100"}
    refute_received {:http, :get, _request, _http_options, _options}
  end

  test "query returns the API error and stops" do
    answer_with([{400, %{"errors" => [%{"code" => "invalidCursor", "message" => "Invalid cursor"}]}}])

    assert [{:error, [%StarkInfra.Error{code: "invalidCursor"}]}] = StarkInfra.AiKnowledgeBase.query() |> Enum.to_list()
  end

  test "query! raises the API error" do
    answer_with([{400, %{"errors" => [%{"code" => "invalidCursor", "message" => "Invalid cursor"}]}}])

    assert_raise RuntimeError, ~r/invalidCursor/, fn -> StarkInfra.AiKnowledgeBase.query!() |> Enum.to_list() end
  end

  test "page returns the items and the cursor, with the parameters in the query string" do
    answer_with([%{"cursor" => "next-page", "knowledgeBases" => [@knowledge_base]}])

    {:ok, {cursor, [knowledge_base]}} = StarkInfra.AiKnowledgeBase.page(cursor: "this-page", limit: 101, ids: ["1", "2"], status: "success")

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert query_of(url) == %{"cursor" => "this-page", "limit" => "101", "ids" => "1,2", "status" => "success"}
    assert cursor == "next-page"
    assert knowledge_base.id == "6767676767676767"
  end

  test "page returns a nil cursor on the last page" do
    answer_with([%{"cursor" => nil, "knowledgeBases" => []}])

    assert {:ok, {nil, []}} = StarkInfra.AiKnowledgeBase.page()
  end

  defp query_of(url) do
    (url |> to_string() |> URI.parse()).query |> Kernel.||("") |> URI.decode_query()
  end

  defp answer_with(bodies) do
    :persistent_term.put(:ai_knowledge_base_test_bodies, bodies)
  end

  defp compile_fake_httpc do
    previous = Code.compiler_options()[:ignore_module_conflict]
    Code.compiler_options(ignore_module_conflict: true)
    Code.compile_quoted(quote do
      defmodule :httpc do
        def request(method, request, http_options, options) do
          send(:persistent_term.get(:ai_knowledge_base_test_pid), {:http, method, request, http_options, options})
          [answer | rest] = :persistent_term.get(:ai_knowledge_base_test_bodies)
          :persistent_term.put(:ai_knowledge_base_test_bodies, rest)
          {status, body} = case answer do
            {status, body} -> {status, body}
            body -> {200, body}
          end
          {:ok, {{~c"HTTP/1.1", status, ~c"OK"}, [], Jason.encode!(body)}}
        end
      end
    end)
    Code.compiler_options(ignore_module_conflict: previous)
  end
end
