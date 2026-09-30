defmodule StarkInfraTest.Ai do
  use ExUnit.Case

  alias StarkInfraTest.Utils.Ai, as: Fixture

  @moduletag :ai

  setup_all do
    {:ok, knowledge_base} = StarkInfra.AiKnowledgeBase.create(StarkInfraTest.Utils.AiKnowledgeBase.example_ai_knowledge_base())
    {:ok, agent} = StarkInfra.AiAgent.create(Fixture.example_ai_agent([knowledge_base.id]))
    {:ok, chat} = StarkInfra.AiChat.create(Fixture.example_ai_chat(agent.id))

    on_exit(fn ->
      StarkInfra.AiChat.delete!([chat.id])
      StarkInfra.AiAgent.delete!([agent.id])
      StarkInfra.AiKnowledgeBase.delete!([knowledge_base.id])
    end)

    {:ok, posted} = StarkInfra.AiMessage.create(
      %StarkInfra.AiMessage{chat_id: chat.id, text: "Say hello and mention order 123."},
      expand: ["chatName"]
    )

    finished_speech = StarkInfra.AiSpeech.query!() |> Enum.find(fn speech -> speech.status == "success" end)
    audio = finished_speech && StarkInfra.AiSpeech.get!(finished_speech.id).audio

    %{knowledge_base: knowledge_base, agent: agent, chat: chat, posted: posted, finished_speech: finished_speech, audio: audio}
  end

  describe "AiVoice" do
    test "create, page and delete", %{audio: audio} do
      with_found(audio, fn audio ->
        {:ok, voice} = StarkInfra.AiVoice.create(%StarkInfra.AiVoice{audio: audio, name: Fixture.unique_name("sdk-elixir-voice"), language: "english"})

        try do
          assert is_binary(voice.id)
          assert voice.status in ["processing", "success", "failed"]
          assert voice.id in (Fixture.all_pages(&StarkInfra.AiVoice.page/1) |> Enum.map(& &1.id))
        after
          assert [%StarkInfra.AiVoice{}] = StarkInfra.AiVoice.delete!([voice.id])
        end
      end)
    end

    test "query" do
      for voice <- StarkInfra.AiVoice.query!() do
        assert is_binary(voice.id)
        assert voice.status in ["processing", "success", "failed"]
        assert is_list(voice.errors)
        assert %DateTime{} = voice.created
      end
    end

    test "query with limit stops at the limit" do
      assert length(StarkInfra.AiVoice.query!(limit: 1) |> Enum.to_list()) <= 1
    end

    test "page with limit 101 returns the API error" do
      assert {:error, [%StarkInfra.Error{code: "invalidLimit"} | _]} = StarkInfra.AiVoice.page(limit: 101)
    end
  end

  describe "AiSpeech" do
    test "create, get and get with expand", %{audio: audio} do
      ready = StarkInfra.AiVoice.query!() |> Enum.find(fn voice -> voice.status == "success" end)

      with_found(audio && ready, fn _ready ->
        {:ok, speech} = StarkInfra.AiSpeech.create(%StarkInfra.AiSpeech{voice_id: ready.id, text: "Short test."})

        assert is_binary(speech.id)
        assert speech.status == "success"
        assert speech.audio != "" and is_binary(speech.audio)
        assert StarkInfra.AiSpeech.get!(speech.id).audio == speech.audio
        assert StarkInfra.AiSpeech.get!(speech.id, expand: ["voiceName"]).voice_name == ready.name
      end)
    end

    test "query leaves the audio out" do
      for speech <- StarkInfra.AiSpeech.query!(limit: 3) do
        assert is_binary(speech.id)
        assert is_nil(speech.audio)
        assert %DateTime{} = speech.created
      end
    end

    test "query with limit stops at the limit" do
      assert length(StarkInfra.AiSpeech.query!(limit: 1) |> Enum.to_list()) <= 1
    end

    test "page follows the cursor until it is nil" do
      speeches = Fixture.all_pages(&StarkInfra.AiSpeech.page/1, limit: 2)

      assert Enum.map(speeches, & &1.id) == Enum.map(StarkInfra.AiSpeech.query!() |> Enum.to_list(), & &1.id)
    end

    test "page with limit 101 returns the API error" do
      assert {:error, [%StarkInfra.Error{code: "invalidLimit"} | _]} = StarkInfra.AiSpeech.page(limit: 101)
    end

    test "get with expand returns the voice name", %{finished_speech: finished_speech} do
      with_found(finished_speech, fn speech ->
        fetched = StarkInfra.AiSpeech.get!(speech.id, expand: ["voiceName"])

        assert is_binary(fetched.voice_name) and fetched.voice_name != ""
      end)
    end

    test "get unknown id returns input errors" do
      assert {:error, [%StarkInfra.Error{code: "invalidSpeechId"} | _]} = StarkInfra.AiSpeech.get("0000000000000000")
    end
  end

  describe "AiTranscript" do
    test "create", %{audio: audio} do
      with_found(audio, fn audio ->
        {:ok, transcript} = StarkInfra.AiTranscript.create(%StarkInfra.AiTranscript{audio: audio})

        assert is_binary(transcript.id)
        assert transcript.status in ["processing", "success", "failed"]
      end)
    end

    test "query" do
      for transcript <- StarkInfra.AiTranscript.query!(limit: 3) do
        assert is_binary(transcript.id)
        assert transcript.status in ["processing", "success", "failed"]
        assert %DateTime{} = transcript.created
      end
    end

    test "page follows the cursor until it is nil" do
      transcripts = Fixture.all_pages(&StarkInfra.AiTranscript.page/1, limit: 2)

      assert Enum.all?(transcripts, fn transcript -> is_binary(transcript.id) end)
    end

    test "page with limit 101 returns the API error" do
      assert {:error, [%StarkInfra.Error{code: "invalidLimit"} | _]} = StarkInfra.AiTranscript.page(limit: 101)
    end
  end

  describe "AiAgent" do
    test "create keeps the schema keys as written", %{agent: agent, knowledge_base: knowledge_base} do
      assert is_binary(agent.id)
      assert agent.model == "bender-1.0"
      assert agent.knowledge_base_ids == [knowledge_base.id]
      assert agent.metadata_schema |> Map.keys() |> Enum.sort() == ["isUrgent", "order_id"]
      assert %DateTime{} = agent.created
    end

    test "get, and get with expand returns the knowledge bases", %{agent: agent, knowledge_base: knowledge_base} do
      plain = StarkInfra.AiAgent.get!(agent.id)
      assert plain.id == agent.id
      assert is_nil(plain.knowledge_bases)

      expanded = StarkInfra.AiAgent.get!(agent.id, expand: ["knowledgeBases"])
      assert [%StarkInfra.AiKnowledgeBase{id: id}] = expanded.knowledge_bases
      assert id == knowledge_base.id
    end

    test "query and page find the agent", %{agent: agent} do
      assert agent.id in (StarkInfra.AiAgent.query!() |> Enum.map(& &1.id))
      assert agent.id in (Fixture.all_pages(&StarkInfra.AiAgent.page/1, limit: 2) |> Enum.map(& &1.id))
    end

    test "query with expand", %{agent: agent, knowledge_base: knowledge_base} do
      found = StarkInfra.AiAgent.query!(expand: ["knowledgeBases"]) |> Enum.find(fn entity -> entity.id == agent.id end)

      assert Enum.map(found.knowledge_bases, & &1.id) == [knowledge_base.id]
    end

    test "page with limit 101 returns the API error" do
      assert {:error, [%StarkInfra.Error{code: "invalidLimit"} | _]} = StarkInfra.AiAgent.page(limit: 101)
    end

    test "update with only a name keeps the other fields", %{knowledge_base: knowledge_base} do
      agent = StarkInfra.AiAgent.create!(Fixture.example_ai_agent([knowledge_base.id]))

      try do
        {:ok, renamed} = StarkInfra.AiAgent.update(agent.id, name: "renamed-by-sdk")

        assert renamed.name == "renamed-by-sdk"
        assert renamed.system_prompt == agent.system_prompt
        assert renamed.knowledge_base_ids == [knowledge_base.id]
        assert renamed.metadata_schema |> Map.keys() |> Enum.sort() == ["isUrgent", "order_id"]
      after
        StarkInfra.AiAgent.delete!([agent.id])
      end
    end

    test "update with an empty list and an empty map clears them", %{knowledge_base: knowledge_base} do
      agent = StarkInfra.AiAgent.create!(Fixture.example_ai_agent([knowledge_base.id]))

      try do
        {:ok, cleared} = StarkInfra.AiAgent.update(agent.id, knowledge_base_ids: [], metadata_schema: %{})

        assert cleared.knowledge_base_ids == []
        assert cleared.metadata_schema == %{}
      after
        StarkInfra.AiAgent.delete!([agent.id])
      end
    end

    test "delete returns the deleted agents" do
      agent = StarkInfra.AiAgent.create!(Fixture.example_ai_agent())

      {:ok, deleted} = StarkInfra.AiAgent.delete([agent.id])

      assert Enum.map(deleted, & &1.id) == [agent.id]
    end

    test "create with an invalid model returns input errors" do
      assert {:error, [%StarkInfra.Error{} | _]} = StarkInfra.AiAgent.create(%StarkInfra.AiAgent{name: "invalid", model: "gpt"})
    end

    test "get unknown id returns input errors" do
      assert {:error, [%StarkInfra.Error{code: "invalidAgentId"} | _]} = StarkInfra.AiAgent.get("0000000000000000")
    end
  end

  describe "AiChat" do
    test "create returns the chat with tags and context", %{chat: chat, agent: agent} do
      assert is_binary(chat.id)
      assert chat.agent_id == agent.id
      assert length(chat.tags) == 2
      assert chat.context == %{"first_name" => "Ana", "isVip" => true}
    end

    test "get, and get with expand returns the agent name", %{chat: chat, agent: agent} do
      assert is_nil(StarkInfra.AiChat.get!(chat.id).agent_name)
      assert StarkInfra.AiChat.get!(chat.id, expand: ["agentName"]).agent_name == agent.name
    end

    test "query and page find the chat", %{chat: chat} do
      assert chat.id in (StarkInfra.AiChat.query!() |> Enum.map(& &1.id))
      assert chat.id in (Fixture.all_pages(&StarkInfra.AiChat.page/1, limit: 2) |> Enum.map(& &1.id))
    end

    test "query and page filter by tags", %{chat: chat} do
      [_shared, own_tag] = chat.tags

      assert [chat.id] == StarkInfra.AiChat.query!(tags: [own_tag]) |> Enum.map(& &1.id)
      assert {:ok, {nil, [%StarkInfra.AiChat{id: id}]}} = StarkInfra.AiChat.page(tags: [own_tag, "no-chat-has-this-tag"])
      assert id == chat.id
    end

    test "page with limit 101 returns the API error" do
      assert {:error, [%StarkInfra.Error{code: "invalidLimit"} | _]} = StarkInfra.AiChat.page(limit: 101)
    end

    test "update changes the title and keeps tags and context", %{chat: chat} do
      {:ok, updated} = StarkInfra.AiChat.update(chat.id, title: "renamed-by-sdk")

      assert updated.title == "renamed-by-sdk"
      assert updated.agent_id == chat.agent_id
      assert updated.tags == chat.tags
      assert updated.context == chat.context
    end

    test "update replaces and clears tags and context", %{agent: agent} do
      chat = StarkInfra.AiChat.create!(Fixture.example_ai_chat(agent.id))

      try do
        {:ok, replaced} = StarkInfra.AiChat.update(chat.id, tags: ["replaced"], context: %{"plan_name" => "gold"})
        assert replaced.tags == ["replaced"]
        assert replaced.context == %{"plan_name" => "gold"}

        {:ok, cleared} = StarkInfra.AiChat.update(chat.id, tags: [], context: %{})
        assert cleared.tags == []
        assert cleared.context == %{}
      after
        StarkInfra.AiChat.delete!([chat.id])
      end
    end

    test "delete returns the deleted chats", %{agent: agent} do
      chat = StarkInfra.AiChat.create!(%StarkInfra.AiChat{agent_id: agent.id, title: "sdk-elixir-delete"})

      {:ok, deleted} = StarkInfra.AiChat.delete([chat.id])

      assert Enum.map(deleted, & &1.id) == [chat.id]
    end

    test "create with an unknown agent returns input errors" do
      assert {:error, [%StarkInfra.Error{} | _]} = StarkInfra.AiChat.create(%StarkInfra.AiChat{agent_id: "0000000000000000"})
    end

    test "get unknown id returns input errors" do
      assert {:error, [%StarkInfra.Error{code: "invalidChatId"} | _]} = StarkInfra.AiChat.get("0000000000000000")
    end
  end

  describe "AiMessage" do
    test "create returns the user message and the answer, with the chat name", %{posted: posted, chat: chat} do
      assert Enum.map(posted, & &1.sender) == ["user", "system"]

      for message <- posted do
        assert message.chat_id == chat.id
        assert %DateTime{} = message.created
        assert is_binary(message.chat_name) and message.chat_name != ""
      end
    end

    test "the answer carries a metadata map", %{posted: [_user_message, answer]} do
      assert is_map(answer.metadata)
    end

    test "query returns the whole history", %{posted: posted, chat: chat} do
      found = StarkInfra.AiMessage.query!(chat_id: chat.id) |> Enum.to_list()

      assert MapSet.new(found, & &1.id) == MapSet.new(posted, & &1.id)
    end

    test "query without a chat id returns the workspace history", %{posted: posted} do
      found = StarkInfra.AiMessage.query!(limit: 200) |> Enum.map(& &1.id)

      assert Enum.all?(posted, fn message -> message.id in found end)
    end

    test "query with limit stops at the limit", %{chat: chat} do
      assert [{:ok, _message}] = StarkInfra.AiMessage.query(chat_id: chat.id, limit: 1) |> Enum.to_list()
    end

    test "page returns a cursor that leads to a different second page", %{chat: chat} do
      {:ok, {cursor, [first]}} = StarkInfra.AiMessage.page(chat_id: chat.id, limit: 1)
      assert is_binary(cursor)

      {:ok, {_cursor, [second]}} = StarkInfra.AiMessage.page(chat_id: chat.id, limit: 1, cursor: cursor)
      assert first.id != second.id
    end

    test "page with limit 101 returns the API error", %{chat: chat} do
      assert {:error, [%StarkInfra.Error{code: "invalidLimit"} | _]} = StarkInfra.AiMessage.page(chat_id: chat.id, limit: 101)
    end

    test "create in an unknown chat returns input errors" do
      assert {:error, [%StarkInfra.Error{} | _]} = StarkInfra.AiMessage.create(%StarkInfra.AiMessage{chat_id: "0000000000000000", text: "hi"})
    end
  end

  defp with_found(nil, _assertions) do
    IO.puts(:stderr, "the workspace has no finished speech to read")
  end

  defp with_found(audio, assertions) do
    assertions.(audio)
  end
end
