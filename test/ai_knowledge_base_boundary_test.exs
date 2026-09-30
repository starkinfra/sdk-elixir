defmodule StarkInfraTest.AiKnowledgeBase.AtTheHttpBoundary do
  use ExUnit.Case

  @moduletag :ai_knowledge_base

  # The sandbox answers 500 to hosts and delete for a valid id, so these two are checked with only the
  # HTTP call replaced, using the payloads documented for the API. Not async: :httpc is swapped VM-wide.
  setup do
    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)
    {_module, original_binary, original_file} = :code.get_object_code(:httpc)
    :persistent_term.put(:ai_knowledge_base_test_pid, self())
    compile_fake_httpc()

    on_exit(fn ->
      :persistent_term.erase(:ai_knowledge_base_test_pid)
      :persistent_term.erase(:ai_knowledge_base_test_body)
      :code.purge(:httpc)
      :code.delete(:httpc)
      :code.purge(:httpc)
      {:module, :httpc} = :code.load_binary(:httpc, original_file, original_binary)
    end)

    :ok
  end

  test "hosts groups pages by host" do
    hosts = %{
      "docs.starkinfra.com" => [%{
        "originalUrl" => "https://docs.starkinfra.com/get-started",
        "status" => "success",
        "storageUrl" => "https://storage.googleapis.com/ai-knowledge/6767676767676767/get-started.md"
      }]
    }
    answer_with(%{"hosts" => hosts})

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
    answer_with(%{
      "knowledgeBases" => [%{
        "id" => "6767676767676767",
        "name" => "Public Documentation",
        "rootUrl" => "https://docs.starkinfra.com",
        "isRecursive" => true,
        "status" => "success",
        "tags" => ["support"],
        "created" => "2022-01-01T00:00:00.000000+00:00",
        "updated" => "2022-01-02T00:00:00.000000+00:00"
      }]
    })

    {:ok, deleted} = StarkInfra.AiKnowledgeBase.delete(["6767676767676767", "6767676767676768"])

    assert_receive {:http, :delete, request, _http_options, _options}
    assert tuple_size(request) == 2
    assert to_string(elem(request, 0)) |> String.ends_with?("/v2/ai-knowledge-base?ids=6767676767676767%2C6767676767676768")
    assert [%StarkInfra.AiKnowledgeBase{id: "6767676767676767", name: "Public Documentation", root_url: "https://docs.starkinfra.com"}] = deleted
  end

  test "create sends only the creatable fields" do
    answer_with(%{"knowledgeBase" => %{"id" => "6767676767676767", "name" => "Public Documentation", "rootUrl" => "https://docs.starkinfra.com"}})

    returned = %StarkInfra.AiKnowledgeBase{
      id: "6767676767676767",
      name: "Public Documentation",
      root_url: "https://docs.starkinfra.com",
      is_recursive: false,
      tags: ["support"],
      status: "success",
      created: ~U[2022-01-01 00:00:00Z],
      updated: ~U[2022-01-02 00:00:00Z]
    }

    {:ok, _created} = StarkInfra.AiKnowledgeBase.create(returned)

    assert_receive {:http, :post, {_url, _headers, _content_type, body}, _http_options, _options}
    assert body |> to_string() |> Jason.decode!() |> Map.keys() |> Enum.sort() == ["isRecursive", "name", "rootUrl", "tags"]
  end

  test "delete! returns the deleted objects" do
    answer_with(%{"knowledgeBases" => [%{"id" => "6767676767676767", "name" => "a", "rootUrl" => "https://docs.starkinfra.com"}]})

    assert [%StarkInfra.AiKnowledgeBase{id: "6767676767676767"}] = StarkInfra.AiKnowledgeBase.delete!(["6767676767676767"])
  end

  defp answer_with(body) do
    :persistent_term.put(:ai_knowledge_base_test_body, Jason.encode!(body))
  end

  defp compile_fake_httpc do
    previous = Code.compiler_options()[:ignore_module_conflict]
    Code.compiler_options(ignore_module_conflict: true)
    Code.compile_quoted(quote do
      defmodule :httpc do
        def request(method, request, http_options, options) do
          send(:persistent_term.get(:ai_knowledge_base_test_pid), {:http, method, request, http_options, options})
          {:ok, {{~c"HTTP/1.1", 200, ~c"OK"}, [], :persistent_term.get(:ai_knowledge_base_test_body)}}
        end
      end
    end)
    Code.compiler_options(ignore_module_conflict: previous)
  end
end
