defmodule StarkInfraTest.Ai.AtTheHttpBoundary do
  use ExUnit.Case

  @moduletag :ai_boundary

  # Voices, speeches and transcripts cannot be deleted and every creation leaves one behind, so creating them is
  # checked with only the HTTP call replaced, using the payloads the API answers. The agent update, the message
  # cursor and the request shapes are checked here too, where the requests can be inspected. Not async: :httpc
  # is swapped VM-wide. This file has no live setup_all on purpose: ExUnit runs it even when other tests are selected.
  setup do
    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)
    {_module, original_binary, original_file} = :code.get_object_code(:httpc)
    :persistent_term.put(:ai_boundary_test_pid, self())
    :persistent_term.put(:ai_boundary_test_bodies, [])
    compile_fake_httpc()

    on_exit(fn ->
      :persistent_term.erase(:ai_boundary_test_pid)
      :persistent_term.erase(:ai_boundary_test_bodies)
      :code.purge(:httpc)
      :code.delete(:httpc)
      :code.purge(:httpc)
      {:module, :httpc} = :code.load_binary(:httpc, original_file, original_binary)
    end)

    :ok
  end

  @voice %{"id" => "5631671361601536", "name" => "Helena", "description" => "Calm voice", "language" => "portuguese", "gender" => "female", "status" => "processing", "errors" => [], "created" => "2026-10-01T14:28:24.566332+00:00", "updated" => "2026-10-01T14:28:24.566342+00:00"}
  @speech %{"id" => "5646488461901824", "voiceId" => "5632499082330112", "text" => "Short test.", "status" => "success", "audio" => "SUQzBAAAAAAA", "errors" => [], "created" => "2026-10-01T14:28:06.942491+00:00", "updated" => "2026-10-01T14:28:07.605185+00:00"}
  @transcript %{"id" => "5147403464212480", "text" => "This is a short recording used to test the transcription service.", "status" => "success", "errors" => [], "created" => "2026-10-01T14:28:04.482326+00:00", "updated" => "2026-10-01T14:28:05.752389+00:00"}
  @agent %{"id" => "5740688905863168", "name" => "Support assistant", "model" => "bender-1.0", "systemPrompt" => "Answer in one short sentence.", "voiceId" => "", "knowledgeBaseIds" => ["5083538508480512"], "metadataSchema" => %{"order_id" => %{"type" => "string"}, "isUrgent" => %{"type" => "boolean"}}, "created" => "2026-09-30T15:42:56.879325+00:00", "updated" => "2026-09-30T15:42:56.879334+00:00"}
  @chat %{"id" => "5761660895625216", "agentId" => "5740688905863168", "title" => "Support chat", "updated" => "2026-09-30T15:42:58.464506+00:00"}
  @user_message %{"id" => "5642368648740864", "chatId" => "5632499082330112", "sender" => "user", "text" => "Say hello.", "speech" => "Say hello.", "metadata" => %{}, "model" => "bender-1.0", "created" => "2026-10-01T14:28:02.652375+00:00"}
  @system_message %{"id" => "5079418695319552", "chatId" => "5632499082330112", "sender" => "system", "text" => "Hello!", "speech" => "Hello!", "metadata" => %{"order_id" => "123", "isUrgent" => false}, "model" => "bender-1.0", "created" => "2026-10-01T14:28:02.653375+00:00"}

  test "voice create sends only the creatable fields" do
    answer_with([%{"voice" => @voice}])
    returned = %StarkInfra.AiVoice{audio: "UklGRg==", name: "Helena", description: "Calm voice", language: "portuguese", gender: "female", id: "5631671361601536", status: "success", errors: [], created: ~U[2026-10-01 14:28:24Z], updated: ~U[2026-10-01 14:28:24Z]}

    {:ok, created} = StarkInfra.AiVoice.create(returned)

    assert_receive {:http, :post, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-voice")
    assert decode(body) == %{"audio" => "UklGRg==", "name" => "Helena", "description" => "Calm voice", "language" => "portuguese", "gender" => "female"}
    assert %StarkInfra.AiVoice{id: "5631671361601536", status: "processing", errors: [], gender: "female"} = created
    assert %DateTime{} = created.created
  end

  test "voice create omits the optional fields it was not given" do
    answer_with([%{"voice" => @voice}])

    {:ok, _created} = StarkInfra.AiVoice.create(%StarkInfra.AiVoice{audio: "UklGRg=="})

    assert_receive {:http, :post, {_url, _headers, _content_type, body}, _http_options, _options}
    assert decode(body) == %{"audio" => "UklGRg=="}
  end

  test "voice query reads the voices key and sends no parameters" do
    answer_with([%{"voices" => [@voice]}])

    [{:ok, voice}] = StarkInfra.AiVoice.query() |> Enum.to_list()

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-voice")
    assert voice.id == "5631671361601536"
  end

  test "voice delete sends ids in the query string, without a body, and returns the deleted objects" do
    answer_with([%{"voices" => [@voice]}])

    {:ok, deleted} = StarkInfra.AiVoice.delete(["5631671361601536", "5631671361601537"])

    assert_receive {:http, :delete, request, _http_options, _options}
    assert tuple_size(request) == 2
    assert to_string(elem(request, 0)) |> String.ends_with?("/v2/ai-voice?ids=5631671361601536%2C5631671361601537")
    assert [%StarkInfra.AiVoice{id: "5631671361601536"}] = deleted
  end

  test "speech create sends only the creatable fields" do
    answer_with([%{"speech" => @speech}])
    returned = %StarkInfra.AiSpeech{voice_id: "5632499082330112", text: "Short test.", id: "5646488461901824", status: "success", audio: "SUQzBAAAAAAA", voice_name: "Fakas", errors: []}

    {:ok, created} = StarkInfra.AiSpeech.create(returned)

    assert_receive {:http, :post, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-speech")
    assert decode(body) == %{"voiceId" => "5632499082330112", "text" => "Short test."}
    assert %StarkInfra.AiSpeech{voice_id: "5632499082330112", audio: "SUQzBAAAAAAA", status: "success"} = created
  end

  test "speech query reads the speeches key and sends fields and expand only" do
    answer_with([%{"speeches" => [@speech]}])

    found = StarkInfra.AiSpeech.query!(fields: [:id, :voice_name], expand: [:voice_name]) |> Enum.to_list()

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    url = to_string(url)
    assert url =~ "fields=id%2CvoiceName"
    assert url =~ "expand=voiceName"
    refute url =~ "limit"
    assert Enum.map(found, & &1.id) == ["5646488461901824"]
  end

  test "speech get reads the speech key" do
    answer_with([%{"speech" => @speech}])

    {:ok, speech} = StarkInfra.AiSpeech.get("5646488461901824")

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-speech/5646488461901824")
    assert speech.audio == "SUQzBAAAAAAA"
  end

  test "transcript create sends only the audio" do
    answer_with([%{"transcript" => @transcript}])
    returned = %StarkInfra.AiTranscript{audio: "UklGRg==", id: "5147403464212480", text: "old", status: "success"}

    {:ok, created} = StarkInfra.AiTranscript.create(returned)

    assert_receive {:http, :post, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-transcript")
    assert decode(body) == %{"audio" => "UklGRg=="}
    assert created.status == "success"
    assert String.starts_with?(created.text, "This is a short recording")
  end

  test "transcript query reads the transcripts key" do
    answer_with([%{"transcripts" => [@transcript]}])

    assert [%StarkInfra.AiTranscript{id: "5147403464212480"}] = StarkInfra.AiTranscript.query!() |> Enum.to_list()
  end

  test "agent create sends only the creatable fields and leaves the schema keys alone" do
    answer_with([%{"agent" => @agent}])
    returned = %StarkInfra.AiAgent{
      name: "Support assistant",
      model: "bender-1.0",
      system_prompt: "Be brief.",
      voice_id: "5632499082330112",
      knowledge_base_ids: [],
      metadata_schema: %{"order_id" => %{"type" => "string"}, "isUrgent" => %{"type" => "boolean"}},
      id: "5740688905863168",
      created: ~U[2026-09-30 15:42:56Z],
      updated: ~U[2026-09-30 15:42:56Z]
    }

    {:ok, created} = StarkInfra.AiAgent.create(returned)

    assert_receive {:http, :post, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-agent")
    assert decode(body) == %{
      "name" => "Support assistant",
      "model" => "bender-1.0",
      "systemPrompt" => "Be brief.",
      "voiceId" => "5632499082330112",
      "knowledgeBaseIds" => [],
      "metadataSchema" => %{"order_id" => %{"type" => "string"}, "isUrgent" => %{"type" => "boolean"}}
    }
    assert created.metadata_schema == %{"order_id" => %{"type" => "string"}, "isUrgent" => %{"type" => "boolean"}}
    assert created.knowledge_base_ids == ["5083538508480512"]
  end

  test "agent get with expand parses the knowledge bases" do
    knowledge_base = %{"id" => "5083538508480512", "name" => "Docs", "rootUrl" => "https://docs.starkinfra.com", "status" => "success"}
    answer_with([%{"agent" => Map.put(@agent, "knowledgeBases", [knowledge_base])}])

    {:ok, agent} = StarkInfra.AiAgent.get("5740688905863168", expand: [:knowledge_bases])

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-agent/5740688905863168?expand=knowledgeBases")
    assert [%StarkInfra.AiKnowledgeBase{id: "5083538508480512", root_url: "https://docs.starkinfra.com"}] = agent.knowledge_bases
  end

  test "agent update without knowledge base ids reads them first and sends them back" do
    answer_with([%{"agent" => %{"id" => "5740688905863168", "knowledgeBaseIds" => ["5083538508480512"]}}, %{"agent" => @agent}])

    {:ok, _updated} = StarkInfra.AiAgent.update("5740688905863168", name: "Renamed")

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-agent/5740688905863168?fields=knowledgeBaseIds")
    assert_receive {:http, :patch, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-agent/5740688905863168")
    assert decode(body) == %{"name" => "Renamed", "knowledgeBaseIds" => ["5083538508480512"]}
  end

  test "an agent fetched without a voice can be created again" do
    answer_with([%{"agent" => @agent}])

    {:ok, _created} = StarkInfra.AiAgent.create(%StarkInfra.AiAgent{name: "a", model: "bender-1.0", voice_id: ""})

    assert_receive {:http, :post, {_url, _headers, _content_type, body}, _http_options, _options}
    assert decode(body) == %{"name" => "a", "model" => "bender-1.0"}
  end

  test "agent update drops an empty voice id" do
    answer_with([%{"agent" => @agent}])

    {:ok, _updated} = StarkInfra.AiAgent.update("5740688905863168", voice_id: "", knowledge_base_ids: [])

    assert_receive {:http, :patch, {_url, _headers, _content_type, body}, _http_options, _options}
    assert decode(body) == %{"knowledgeBaseIds" => []}
  end

  test "agent update with knowledge base ids does not read the agent" do
    answer_with([%{"agent" => @agent}])

    {:ok, _updated} = StarkInfra.AiAgent.update("5740688905863168", knowledge_base_ids: [])

    assert_receive {:http, :patch, {_url, _headers, _content_type, body}, _http_options, _options}
    assert decode(body) == %{"knowledgeBaseIds" => []}
    refute_received {:http, :get, _request, _http_options, _options}
  end

  test "agent update leaves the schema keys alone" do
    answer_with([%{"agent" => @agent}])

    {:ok, _updated} = StarkInfra.AiAgent.update("5740688905863168", knowledge_base_ids: ["5083538508480512"], metadata_schema: %{"order_id" => %{"type" => "string"}, "isUrgent" => %{"type" => "boolean"}})

    assert_receive {:http, :patch, {_url, _headers, _content_type, body}, _http_options, _options}
    assert decode(body)["metadataSchema"] == %{"order_id" => %{"type" => "string"}, "isUrgent" => %{"type" => "boolean"}}
  end

  test "agent update returns the error of the read and does not patch" do
    answer_with([{400, %{"errors" => [%{"code" => "invalidAgentId", "message" => "Invalid agent id"}]}}])

    {:error, [error | _]} = StarkInfra.AiAgent.update("0000000000000000", name: "Renamed")

    assert error.code == "invalidAgentId"
    refute_received {:http, :patch, _request, _http_options, _options}
  end

  test "agent delete sends ids in the query string and returns the deleted objects" do
    answer_with([%{"agents" => [@agent]}])

    assert [%StarkInfra.AiAgent{id: "5740688905863168"}] = StarkInfra.AiAgent.delete!(["5740688905863168", "5740688905863169"])

    assert_receive {:http, :delete, request, _http_options, _options}
    assert tuple_size(request) == 2
    assert to_string(elem(request, 0)) |> String.ends_with?("/v2/ai-agent?ids=5740688905863168%2C5740688905863169")
  end

  test "chat create sends only the creatable fields" do
    answer_with([%{"chat" => @chat}])
    returned = %StarkInfra.AiChat{agent_id: "5740688905863168", title: "Support chat", id: "5761660895625216", agent_name: "Support assistant", updated: ~U[2026-09-30 15:42:58Z]}

    {:ok, _created} = StarkInfra.AiChat.create(returned)

    assert_receive {:http, :post, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-chat")
    assert decode(body) == %{"agentId" => "5740688905863168", "title" => "Support chat"}
  end

  test "chat update sends only the given fields" do
    answer_with([%{"chat" => @chat}])

    {:ok, _updated} = StarkInfra.AiChat.update("5761660895625216", title: "New title")

    assert_receive {:http, :patch, {_url, _headers, _content_type, body}, _http_options, _options}
    assert decode(body) == %{"title" => "New title"}
  end

  test "chat update without fields sends an empty object" do
    answer_with([%{"chat" => @chat}])

    {:ok, _updated} = StarkInfra.AiChat.update("5761660895625216")

    assert_receive {:http, :patch, {_url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(body) == "{}"
  end

  test "chat get sends expand in the query string" do
    answer_with([%{"chat" => Map.put(@chat, "agentName", "Support assistant")}])

    {:ok, chat} = StarkInfra.AiChat.get("5761660895625216", expand: [:agent_name])

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-chat/5761660895625216?expand=agentName")
    assert chat.agent_name == "Support assistant"
  end

  test "message create has expand in the query string and not in the body" do
    answer_with([%{"chatName" => "Greeting", "messages" => [@user_message, @system_message]}])
    message = %StarkInfra.AiMessage{chat_id: "5632499082330112", text: "Say hello.", model: "prime-1.0", id: "1", sender: "user", created: ~U[2026-10-01 14:28:02Z]}

    {:ok, [user_message, answer]} = StarkInfra.AiMessage.create(message, expand: [:chat_name])

    assert_receive {:http, :post, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-message?expand=chatName")
    assert decode(body) == %{"chatId" => "5632499082330112", "text" => "Say hello.", "model" => "prime-1.0"}
    assert [user_message.sender, answer.sender] == ["user", "system"]
    assert [user_message.chat_name, answer.chat_name] == ["Greeting", "Greeting"]
    assert answer.metadata == %{"order_id" => "123", "isUrgent" => false}
  end

  test "message create without expand leaves the chat name empty" do
    answer_with([%{"messages" => [@user_message, @system_message]}])

    {:ok, messages} = StarkInfra.AiMessage.create(%StarkInfra.AiMessage{chat_id: "5632499082330112", text: "Say hello."})

    assert_receive {:http, :post, {url, _headers, _content_type, _body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-message")
    assert Enum.map(messages, & &1.chat_name) == [nil, nil]
  end

  test "message query follows the cursor across two pages" do
    answer_with([
      %{"cursor" => "next-page", "messages" => [@user_message]},
      %{"cursor" => nil, "messages" => [@system_message]}
    ])

    found = StarkInfra.AiMessage.query!(chat_id: "5632499082330112") |> Enum.to_list()

    assert Enum.map(found, & &1.id) == ["5642368648740864", "5079418695319552"]
    assert_receive {:http, :get, {first_url, _headers}, _http_options, _options}
    assert to_string(first_url) =~ "chatId=5632499082330112"
    refute to_string(first_url) =~ "cursor"
    assert_receive {:http, :get, {second_url, _headers}, _http_options, _options}
    assert to_string(second_url) =~ "cursor=next-page"
  end

  test "message query with limit stops at the limit without asking for another page" do
    answer_with([%{"cursor" => "next-page", "messages" => [@user_message, @system_message]}])

    found = StarkInfra.AiMessage.query(chat_id: "5632499082330112", limit: 1) |> Enum.to_list()

    assert [{:ok, %StarkInfra.AiMessage{id: "5642368648740864"}}] = found
    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert to_string(url) =~ "limit=1"
    refute_received {:http, :get, _request, _http_options, _options}
  end

  test "message page returns the cursor and the messages" do
    answer_with([%{"cursor" => "next-page", "messages" => [@user_message]}])

    {:ok, {cursor, [message]}} = StarkInfra.AiMessage.page(chat_id: "5632499082330112", limit: 1, cursor: "this-page")

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert to_string(url) =~ "cursor=this-page"
    assert cursor == "next-page"
    assert message.id == "5642368648740864"
  end

  test "message query requires a chat id" do
    assert_raise KeyError, fn -> StarkInfra.AiMessage.query(limit: 1) |> Enum.to_list() end
  end

  defp answer_with(bodies) do
    :persistent_term.put(:ai_boundary_test_bodies, bodies)
  end

  defp decode(body) do
    body |> to_string() |> Jason.decode!()
  end

  defp compile_fake_httpc do
    previous = Code.compiler_options()[:ignore_module_conflict]
    Code.compiler_options(ignore_module_conflict: true)
    Code.compile_quoted(quote do
      defmodule :httpc do
        def request(method, request, http_options, options) do
          send(:persistent_term.get(:ai_boundary_test_pid), {:http, method, request, http_options, options})
          [answer | rest] = :persistent_term.get(:ai_boundary_test_bodies)
          :persistent_term.put(:ai_boundary_test_bodies, rest)
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
