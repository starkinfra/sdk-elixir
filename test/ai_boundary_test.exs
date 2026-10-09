defmodule StarkInfraTest.Ai.AtTheHttpBoundary do
  use ExUnit.Case

  @moduletag :ai_boundary

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
  @chat %{"id" => "5761660895625216", "agentId" => "5740688905863168", "title" => "Support chat", "tags" => ["vip"], "context" => %{"first_name" => "Ana", "isVip" => true}, "updated" => "2026-09-30T15:42:58.464506+00:00"}
  @user_message %{"id" => "5642368648740864", "chatId" => "5632499082330112", "sender" => "user", "text" => "Say hello.", "speech" => "Say hello.", "metadata" => %{}, "model" => "bender-1.0", "created" => "2026-10-01T14:28:02.652375+00:00"}
  @system_message %{"id" => "5079418695319552", "chatId" => "5632499082330112", "sender" => "system", "text" => "Hello!", "speech" => "Hello!", "metadata" => %{"order_id" => "123", "isUrgent" => false}, "model" => "bender-1.0", "created" => "2026-10-01T14:28:02.653375+00:00"}

  test "voice create sends the given fields and leaves out the nil ones" do
    answer_with([%{"voice" => @voice}, %{"voice" => @voice}])

    {:ok, created} = StarkInfra.AiVoice.create(%StarkInfra.AiVoice{audio: "UklGRg==", name: "Helena", gender: "female"})
    {:ok, _created} = StarkInfra.AiVoice.create(%StarkInfra.AiVoice{audio: "UklGRg=="})

    assert_receive {:http, :post, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-voice")
    assert decode(body) == %{"audio" => "UklGRg==", "name" => "Helena", "gender" => "female"}
    assert_receive {:http, :post, {_url, _headers, _content_type, second_body}, _http_options, _options}
    assert decode(second_body) == %{"audio" => "UklGRg=="}
    assert %StarkInfra.AiVoice{id: "5631671361601536", status: "processing", errors: [], gender: "female"} = created
    assert %DateTime{} = created.created
  end

  test "voice query reads the voices key and sends no parameters" do
    answer_with([%{"voices" => [@voice]}])

    [{:ok, voice}] = StarkInfra.AiVoice.query() |> Enum.to_list()

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-voice")
    assert voice.id == "5631671361601536"
  end

  test "voice page returns the items and the cursor, with limit and cursor in the query string" do
    answer_with([%{"cursor" => "next-page", "voices" => [@voice]}])

    {:ok, {cursor, [voice]}} = StarkInfra.AiVoice.page(cursor: "this-page", limit: 1)

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert query_of(url) == %{"cursor" => "this-page", "limit" => "1"}
    assert cursor == "next-page"
    assert voice.id == "5631671361601536"
  end

  test "voice page returns a nil cursor on the last page" do
    answer_with([%{"cursor" => nil, "voices" => [@voice]}])

    assert {:ok, {nil, [%StarkInfra.AiVoice{}]}} = StarkInfra.AiVoice.page()
  end

  test "voice page sends the limit as given" do
    answer_with([%{"cursor" => nil, "voices" => []}])

    StarkInfra.AiVoice.page!(limit: 101)

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert query_of(url) == %{"limit" => "101"}
  end

  test "voice delete sends ids in the query string, without a body, and returns the deleted objects" do
    answer_with([%{"voices" => [@voice]}])

    {:ok, deleted} = StarkInfra.AiVoice.delete(["5631671361601536", "5631671361601537"])

    assert_receive {:http, :delete, request, _http_options, _options}
    assert tuple_size(request) == 2
    assert to_string(elem(request, 0)) |> String.ends_with?("/v2/ai-voice?ids=5631671361601536%2C5631671361601537")
    assert [%StarkInfra.AiVoice{id: "5631671361601536"}] = deleted
  end

  test "speech create sends the given fields" do
    answer_with([%{"speech" => @speech}])

    {:ok, created} = StarkInfra.AiSpeech.create(%StarkInfra.AiSpeech{voice_id: "5632499082330112", text: "Short test."})

    assert_receive {:http, :post, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-speech")
    assert decode(body) == %{"voiceId" => "5632499082330112", "text" => "Short test."}
    assert %StarkInfra.AiSpeech{voice_id: "5632499082330112", audio: "SUQzBAAAAAAA", status: "success"} = created
  end

  test "speech query reads the speeches key and sends expand only" do
    answer_with([%{"speeches" => [@speech]}])

    found = StarkInfra.AiSpeech.query!(expand: ["voiceName"]) |> Enum.to_list()

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert query_of(url) == %{"expand" => "voiceName"}
    assert Enum.map(found, & &1.id) == ["5646488461901824"]
  end

  test "speech query follows the cursor through an empty page" do
    answer_with([
      %{"cursor" => "second", "speeches" => [@speech]},
      %{"cursor" => "third", "speeches" => []},
      %{"cursor" => nil, "speeches" => [@speech]}
    ])

    found = StarkInfra.AiSpeech.query!() |> Enum.to_list()

    assert length(found) == 2
    assert_receive {:http, :get, {first_url, _headers}, _http_options, _options}
    assert query_of(first_url) == %{}
    assert_receive {:http, :get, {second_url, _headers}, _http_options, _options}
    assert query_of(second_url) == %{"cursor" => "second"}
    assert_receive {:http, :get, {third_url, _headers}, _http_options, _options}
    assert query_of(third_url) == %{"cursor" => "third"}
    refute_received {:http, :get, _request, _http_options, _options}
  end

  test "speech query with limit 150 asks for 100 and then 50" do
    answer_with([
      %{"cursor" => "second", "speeches" => [@speech]},
      %{"cursor" => "third", "speeches" => [@speech]}
    ])

    StarkInfra.AiSpeech.query!(limit: 150) |> Enum.to_list()

    assert_receive {:http, :get, {first_url, _headers}, _http_options, _options}
    assert query_of(first_url) == %{"limit" => "100"}
    assert_receive {:http, :get, {second_url, _headers}, _http_options, _options}
    assert query_of(second_url) == %{"cursor" => "second", "limit" => "50"}
    refute_received {:http, :get, _request, _http_options, _options}
  end

  test "speech query stops at the limit even when the API still has a cursor" do
    answer_with([%{"cursor" => "second", "speeches" => [@speech]}])

    StarkInfra.AiSpeech.query!(limit: 100) |> Enum.to_list()

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert query_of(url) == %{"limit" => "100"}
    refute_received {:http, :get, _request, _http_options, _options}
  end

  test "speech query returns the API error" do
    answer_with([{400, %{"errors" => [%{"code" => "invalidCursor", "message" => "Invalid cursor"}]}}])

    assert [{:error, [%StarkInfra.Error{code: "invalidCursor"}]}] = StarkInfra.AiSpeech.query() |> Enum.to_list()
  end

  test "speech page reads the speeches key and returns the cursor" do
    answer_with([%{"cursor" => "next-page", "speeches" => [@speech]}])

    {:ok, {cursor, [speech]}} = StarkInfra.AiSpeech.page(cursor: "this-page", limit: 101, expand: ["voiceName"])

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert query_of(url) == %{"cursor" => "this-page", "limit" => "101", "expand" => "voiceName"}
    assert cursor == "next-page"
    assert speech.id == "5646488461901824"
  end

  test "speech page returns a nil cursor on the last page" do
    answer_with([%{"cursor" => nil, "speeches" => []}])

    assert {:ok, {nil, []}} = StarkInfra.AiSpeech.page()
  end

  test "speech get reads the speech key and sends expand" do
    answer_with([%{"speech" => @speech}])

    {:ok, speech} = StarkInfra.AiSpeech.get("5646488461901824", expand: ["voiceName"])

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-speech/5646488461901824?expand=voiceName")
    assert speech.audio == "SUQzBAAAAAAA"
  end

  test "transcript create sends only the given fields" do
    answer_with([%{"transcript" => @transcript}])

    {:ok, created} = StarkInfra.AiTranscript.create(%StarkInfra.AiTranscript{audio: "UklGRg=="})

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

  test "transcript page returns the items and the cursor" do
    answer_with([%{"cursor" => "next-page", "transcripts" => [@transcript]}])

    {:ok, {cursor, [transcript]}} = StarkInfra.AiTranscript.page(limit: 1)

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert query_of(url) == %{"limit" => "1"}
    assert cursor == "next-page"
    assert transcript.id == "5147403464212480"
  end

  test "agent create sends the given fields and leaves the schema keys alone" do
    answer_with([%{"agent" => @agent}])

    {:ok, created} = StarkInfra.AiAgent.create(%StarkInfra.AiAgent{
      name: "Support assistant",
      model: "bender-1.0",
      system_prompt: "Be brief.",
      knowledge_base_ids: [],
      metadata_schema: %{"order_id" => %{"type" => "string", "is_required" => nil}, "isUrgent" => %{"type" => "boolean"}}
    })

    assert_receive {:http, :post, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-agent")
    assert decode(body) == %{
      "name" => "Support assistant",
      "model" => "bender-1.0",
      "systemPrompt" => "Be brief.",
      "knowledgeBaseIds" => [],
      "metadataSchema" => %{"order_id" => %{"type" => "string", "is_required" => nil}, "isUrgent" => %{"type" => "boolean"}}
    }
    assert created.metadata_schema == %{"order_id" => %{"type" => "string"}, "isUrgent" => %{"type" => "boolean"}}
    assert created.knowledge_base_ids == ["5083538508480512"]
  end

  test "agent get with expand parses the knowledge bases" do
    knowledge_base = %{"id" => "5083538508480512", "name" => "Docs", "rootUrl" => "https://docs.starkinfra.com", "status" => "success"}
    answer_with([%{"agent" => Map.put(@agent, "knowledgeBases", [knowledge_base])}])

    {:ok, agent} = StarkInfra.AiAgent.get("5740688905863168", expand: ["knowledgeBases"])

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-agent/5740688905863168?expand=knowledgeBases")
    assert [%StarkInfra.AiKnowledgeBase{id: "5083538508480512", root_url: "https://docs.starkinfra.com"}] = agent.knowledge_bases
  end

  test "agent update names every key, sends the absent ones as null and does not read the agent first" do
    answer_with([%{"agent" => @agent}])

    {:ok, _updated} = StarkInfra.AiAgent.update("5740688905863168", name: "Renamed")

    assert_receive {:http, :patch, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-agent/5740688905863168")
    assert decode(body) == %{
      "name" => "Renamed",
      "model" => nil,
      "systemPrompt" => nil,
      "voiceId" => nil,
      "knowledgeBaseIds" => nil,
      "metadataSchema" => nil
    }
    refute_received {:http, :get, _request, _http_options, _options}
  end

  test "agent update sends empty values as they are" do
    answer_with([%{"agent" => @agent}])

    {:ok, _updated} = StarkInfra.AiAgent.update("5740688905863168", system_prompt: "", voice_id: "", knowledge_base_ids: [], metadata_schema: %{})

    assert_receive {:http, :patch, {_url, _headers, _content_type, body}, _http_options, _options}
    assert decode(body) == %{
      "name" => nil,
      "model" => nil,
      "systemPrompt" => "",
      "voiceId" => "",
      "knowledgeBaseIds" => [],
      "metadataSchema" => %{}
    }
  end

  test "agent update leaves the schema keys alone" do
    answer_with([%{"agent" => @agent}])

    {:ok, _updated} = StarkInfra.AiAgent.update("5740688905863168", metadata_schema: %{"order_id" => %{"type" => "string"}, "isUrgent" => %{"type" => "boolean"}})

    assert_receive {:http, :patch, {_url, _headers, _content_type, body}, _http_options, _options}
    assert decode(body)["metadataSchema"] == %{"order_id" => %{"type" => "string"}, "isUrgent" => %{"type" => "boolean"}}
  end

  test "agent update returns the API error" do
    answer_with([{400, %{"errors" => [%{"code" => "invalidAgentId", "message" => "Invalid agent id"}]}}])

    {:error, [error | _]} = StarkInfra.AiAgent.update("0000000000000000", name: "Renamed")

    assert %StarkInfra.Error{code: "invalidAgentId"} = error
  end

  test "agent query follows the cursor and sends expand" do
    answer_with([
      %{"cursor" => "next-page", "agents" => [@agent]},
      %{"cursor" => nil, "agents" => [@agent]}
    ])

    found = StarkInfra.AiAgent.query!(expand: ["knowledgeBases"]) |> Enum.to_list()

    assert length(found) == 2
    assert_receive {:http, :get, {first_url, _headers}, _http_options, _options}
    assert query_of(first_url) == %{"expand" => "knowledgeBases"}
    assert_receive {:http, :get, {second_url, _headers}, _http_options, _options}
    assert query_of(second_url) == %{"expand" => "knowledgeBases", "cursor" => "next-page"}
  end

  test "agent page returns the items and the cursor" do
    answer_with([%{"cursor" => "next-page", "agents" => [@agent]}])

    {:ok, {cursor, [agent]}} = StarkInfra.AiAgent.page(limit: 1, expand: ["knowledgeBases"])

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert query_of(url) == %{"limit" => "1", "expand" => "knowledgeBases"}
    assert cursor == "next-page"
    assert agent.id == "5740688905863168"
  end

  test "agent delete sends ids in the query string and returns the deleted objects" do
    answer_with([%{"agents" => [@agent]}])

    assert [%StarkInfra.AiAgent{id: "5740688905863168"}] = StarkInfra.AiAgent.delete!(["5740688905863168", "5740688905863169"])

    assert_receive {:http, :delete, request, _http_options, _options}
    assert tuple_size(request) == 2
    assert to_string(elem(request, 0)) |> String.ends_with?("/v2/ai-agent?ids=5740688905863168%2C5740688905863169")
  end

  test "chat create sends tags and context with the context keys untouched" do
    answer_with([%{"chat" => @chat}])

    {:ok, created} = StarkInfra.AiChat.create(%StarkInfra.AiChat{
      agent_id: "5740688905863168",
      title: "Support chat",
      tags: ["vip"],
      context: %{"first_name" => "Ana", "isVip" => true}
    })

    assert_receive {:http, :post, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-chat")
    assert decode(body) == %{
      "agentId" => "5740688905863168",
      "title" => "Support chat",
      "tags" => ["vip"],
      "context" => %{"first_name" => "Ana", "isVip" => true}
    }
    assert created.tags == ["vip"]
    assert created.context == %{"first_name" => "Ana", "isVip" => true}
  end

  test "chat create leaves out what it was not given" do
    answer_with([%{"chat" => @chat}])

    {:ok, _created} = StarkInfra.AiChat.create(%StarkInfra.AiChat{agent_id: "5740688905863168"})

    assert_receive {:http, :post, {_url, _headers, _content_type, body}, _http_options, _options}
    assert decode(body) == %{"agentId" => "5740688905863168"}
  end

  test "agent create sends an empty metadata schema and nested nils inside it" do
    answer_with([%{"agent" => @agent}, %{"agent" => @agent}])

    {:ok, _created} = StarkInfra.AiAgent.create(%StarkInfra.AiAgent{name: "a", model: "bender-1.0", knowledge_base_ids: [], metadata_schema: %{}})
    {:ok, _created} = StarkInfra.AiAgent.create(%StarkInfra.AiAgent{name: "a", model: "bender-1.0", metadata_schema: %{"order_id" => nil}})

    assert_receive {:http, :post, {_url, _headers, _content_type, body}, _http_options, _options}
    assert decode(body) == %{"name" => "a", "model" => "bender-1.0", "knowledgeBaseIds" => [], "metadataSchema" => %{}}
    assert_receive {:http, :post, {_url, _headers, _content_type, second_body}, _http_options, _options}
    assert decode(second_body)["metadataSchema"] == %{"order_id" => nil}
  end

  test "chat create sends empty tags and context and nested nils inside the context" do
    answer_with([%{"chat" => @chat}, %{"chat" => @chat}])

    {:ok, _created} = StarkInfra.AiChat.create(%StarkInfra.AiChat{agent_id: "1", tags: [], context: %{}})
    {:ok, _created} = StarkInfra.AiChat.create(%StarkInfra.AiChat{agent_id: "1", context: %{"first_name" => nil, "isVip" => true}})

    assert_receive {:http, :post, {_url, _headers, _content_type, body}, _http_options, _options}
    assert decode(body) == %{"agentId" => "1", "tags" => [], "context" => %{}}
    assert_receive {:http, :post, {_url, _headers, _content_type, second_body}, _http_options, _options}
    assert decode(second_body)["context"] == %{"first_name" => nil, "isVip" => true}
  end

  test "non-ASCII text travels as UTF-8 in message, chat, agent and knowledge base bodies" do
    text = "olá 日本 \"q\" 😀 “curly” ‘quotes’"
    answer_with([%{"messages" => [@user_message]}, %{"chat" => @chat}, %{"agent" => @agent}, %{"knowledgeBase" => %{"id" => "1", "name" => text}}])

    {:ok, _created} = StarkInfra.AiMessage.create(%StarkInfra.AiMessage{chat_id: "1", text: text})
    {:ok, _created} = StarkInfra.AiChat.create(%StarkInfra.AiChat{agent_id: "1", title: text, tags: [text], context: %{"nome" => text}})
    {:ok, _created} = StarkInfra.AiAgent.create(%StarkInfra.AiAgent{name: "a", model: "bender-1.0", system_prompt: text})
    {:ok, _created} = StarkInfra.AiKnowledgeBase.create(%StarkInfra.AiKnowledgeBase{name: text, root_url: "https://docs.starkinfra.com"})

    assert_receive {:http, :post, {_url, _headers, _content_type, message_body}, _http_options, _options}
    assert decode(message_body)["text"] == text
    assert String.valid?(to_string(message_body)) and to_string(message_body) =~ "日本"
    assert_receive {:http, :post, {_url, _headers, _content_type, chat_body}, _http_options, _options}
    assert %{"title" => ^text, "tags" => [^text], "context" => %{"nome" => ^text}} = decode(chat_body)
    assert_receive {:http, :post, {_url, _headers, _content_type, agent_body}, _http_options, _options}
    assert decode(agent_body)["systemPrompt"] == text
    assert_receive {:http, :post, {_url, _headers, _content_type, knowledge_base_body}, _http_options, _options}
    assert decode(knowledge_base_body)["name"] == text
  end

  test "non-ASCII tags are percent-encoded in the query string" do
    answer_with([%{"cursor" => nil, "chats" => []}])

    StarkInfra.AiChat.page!(tags: ["olá", "日本"])

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert to_string(url) =~ "tags=ol%C3%A1%2C%E6%97%A5%E6%9C%AC"
    assert query_of(url) == %{"tags" => "olá,日本"}
  end

  test "chat update names every key and sends the absent ones as null" do
    answer_with([%{"chat" => @chat}])

    {:ok, _updated} = StarkInfra.AiChat.update("5761660895625216", title: "New title")

    assert_receive {:http, :patch, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-chat/5761660895625216")
    assert decode(body) == %{"title" => "New title", "agentId" => nil, "tags" => nil, "context" => nil}
  end

  test "chat update sends empty values and leaves the context keys untouched" do
    answer_with([%{"chat" => @chat}, %{"chat" => @chat}])

    {:ok, _updated} = StarkInfra.AiChat.update("5761660895625216", title: "", tags: [], context: %{})
    {:ok, _updated} = StarkInfra.AiChat.update("5761660895625216", context: %{"first_name" => "Ana", "isVip" => nil})

    assert_receive {:http, :patch, {_url, _headers, _content_type, body}, _http_options, _options}
    assert decode(body) == %{"title" => "", "agentId" => nil, "tags" => [], "context" => %{}}
    assert_receive {:http, :patch, {_url, _headers, _content_type, second_body}, _http_options, _options}
    assert decode(second_body)["context"] == %{"first_name" => "Ana", "isVip" => nil}
  end

  test "chat get sends expand in the query string" do
    answer_with([%{"chat" => Map.put(@chat, "agentName", "Support assistant")}])

    {:ok, chat} = StarkInfra.AiChat.get("5761660895625216", expand: ["agentName"])

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-chat/5761660895625216?expand=agentName")
    assert chat.agent_name == "Support assistant"
  end

  test "chat query sends the tags comma-separated and follows the cursor" do
    answer_with([
      %{"cursor" => "next-page", "chats" => [@chat]},
      %{"cursor" => nil, "chats" => [@chat]}
    ])

    found = StarkInfra.AiChat.query!(tags: ["vip", "whatsapp"], expand: ["agentName"]) |> Enum.to_list()

    assert length(found) == 2
    assert_receive {:http, :get, {first_url, _headers}, _http_options, _options}
    assert query_of(first_url) == %{"tags" => "vip,whatsapp", "expand" => "agentName"}
    assert_receive {:http, :get, {second_url, _headers}, _http_options, _options}
    assert query_of(second_url)["cursor"] == "next-page"
  end

  test "chat page returns the items and the cursor" do
    answer_with([%{"cursor" => "next-page", "chats" => [@chat]}])

    {:ok, {cursor, [chat]}} = StarkInfra.AiChat.page(cursor: "this-page", limit: 1, tags: ["vip"])

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert query_of(url) == %{"cursor" => "this-page", "limit" => "1", "tags" => "vip"}
    assert cursor == "next-page"
    assert chat.tags == ["vip"]
  end

  test "chat page returns a nil cursor on the last page" do
    answer_with([%{"cursor" => nil, "chats" => [@chat]}])

    assert {:ok, {nil, [%StarkInfra.AiChat{}]}} = StarkInfra.AiChat.page()
  end

  test "chat delete sends ids in the query string and returns the deleted objects" do
    answer_with([%{"chats" => [@chat]}])

    assert [%StarkInfra.AiChat{id: "5761660895625216"}] = StarkInfra.AiChat.delete!(["5761660895625216", "5761660895625217"])

    assert_receive {:http, :delete, request, _http_options, _options}
    assert tuple_size(request) == 2
    assert to_string(elem(request, 0)) |> String.ends_with?("/v2/ai-chat?ids=5761660895625216%2C5761660895625217")
  end

  test "message create has expand in the query string and not in the body" do
    answer_with([%{"chatName" => "Greeting", "messages" => [@user_message, @system_message]}])
    message = %StarkInfra.AiMessage{chat_id: "5632499082330112", text: "Say hello.", model: "prime-1.0"}

    {:ok, [user_message, answer]} = StarkInfra.AiMessage.create(message, expand: ["chatName"])

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

    assert_receive {:http, :post, {url, _headers, _content_type, body}, _http_options, _options}
    assert to_string(url) |> String.ends_with?("/v2/ai-message")
    assert decode(body) == %{"chatId" => "5632499082330112", "text" => "Say hello."}
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
    assert query_of(first_url) == %{"chatId" => "5632499082330112"}
    assert_receive {:http, :get, {second_url, _headers}, _http_options, _options}
    assert query_of(second_url) == %{"chatId" => "5632499082330112", "cursor" => "next-page"}
  end

  test "message query without a chat id leaves it out of the URL" do
    answer_with([%{"cursor" => nil, "messages" => [@user_message]}])

    [%StarkInfra.AiMessage{}] = StarkInfra.AiMessage.query!() |> Enum.to_list()

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert query_of(url) == %{}
  end

  test "message query with limit 150 asks for 100 and then 50" do
    answer_with([
      %{"cursor" => "next-page", "messages" => [@user_message]},
      %{"cursor" => nil, "messages" => [@system_message]}
    ])

    StarkInfra.AiMessage.query!(limit: 150) |> Enum.to_list()

    assert_receive {:http, :get, {first_url, _headers}, _http_options, _options}
    assert query_of(first_url) == %{"limit" => "100"}
    assert_receive {:http, :get, {second_url, _headers}, _http_options, _options}
    assert query_of(second_url) == %{"cursor" => "next-page", "limit" => "50"}
  end

  test "message page returns the cursor and the messages" do
    answer_with([%{"cursor" => "next-page", "messages" => [@user_message]}])

    {:ok, {cursor, [message]}} = StarkInfra.AiMessage.page(chat_id: "5632499082330112", limit: 1, cursor: "this-page")

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert query_of(url) == %{"chatId" => "5632499082330112", "cursor" => "this-page", "limit" => "1"}
    assert cursor == "next-page"
    assert message.id == "5642368648740864"
  end

  test "message page without a chat id returns a nil cursor on the last page" do
    answer_with([%{"cursor" => nil, "messages" => [@system_message]}])

    assert {:ok, {nil, [%StarkInfra.AiMessage{}]}} = StarkInfra.AiMessage.page()

    assert_receive {:http, :get, {url, _headers}, _http_options, _options}
    assert query_of(url) == %{}
  end

  defp query_of(url) do
    (url |> to_string() |> URI.parse()).query |> Kernel.||("") |> URI.decode_query()
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
