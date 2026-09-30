defmodule StarkInfraTest.Ai do
  use ExUnit.Case

  alias StarkInfraTest.Utils.Ai, as: Fixture

  @moduletag :ai

  # Voices, speeches and transcripts cannot be deleted and every creation leaves one behind, so they are only
  # read here; their creation is checked in ai_boundary_test.exs. Knowledge base, agent, chat and message can be
  # deleted: one of each is created for the whole run, the tests only read them (the ones that change something
  # use their own short-lived entities or put it back), and on_exit removes them.
  setup_all do
    {:ok, knowledge_base} = StarkInfra.AiKnowledgeBase.create(StarkInfraTest.Utils.AiKnowledgeBase.example_ai_knowledge_base())
    {:ok, agent} = StarkInfra.AiAgent.create(Fixture.example_ai_agent([knowledge_base.id]))
    {:ok, chat} = StarkInfra.AiChat.create(%StarkInfra.AiChat{agent_id: agent.id, title: Fixture.unique_name("sdk-elixir-chat")})

    on_exit(fn ->
      Fixture.delete_or_warn(StarkInfra.AiChat, "AiChat", chat.id)
      Fixture.delete_or_warn(StarkInfra.AiAgent, "AiAgent", agent.id)
      Fixture.delete_or_warn(StarkInfra.AiKnowledgeBase, "AiKnowledgeBase", knowledge_base.id)
    end)

    {:ok, posted} = StarkInfra.AiMessage.create(
      %StarkInfra.AiMessage{chat_id: chat.id, text: "Say hello and mention order 123."},
      expand: [:chat_name]
    )

    finished_speech = StarkInfra.AiSpeech.query!() |> Enum.find(fn speech -> speech.status == "success" end)

    %{knowledge_base: knowledge_base, agent: agent, chat: chat, posted: posted, finished_speech: finished_speech}
  end

  describe "AiVoice" do
    test "query" do
      for voice <- StarkInfra.AiVoice.query!() do
        assert is_binary(voice.id)
        assert voice.status in ["processing", "success", "failed"]
        assert is_list(voice.errors)
        assert %DateTime{} = voice.created
      end
    end
  end

  describe "AiSpeech" do
    test "query leaves the audio out" do
      for speech <- StarkInfra.AiSpeech.query!() do
        assert is_binary(speech.id)
        assert is_nil(speech.audio)
        assert %DateTime{} = speech.created
      end
    end

    test "query with fields keeps only what was asked" do
      for speech <- StarkInfra.AiSpeech.query!(fields: [:id, :status]) do
        assert is_binary(speech.id)
        assert is_nil(speech.text)
      end
    end

    test "get returns the audio", %{finished_speech: finished_speech} do
      with_finished_speech(finished_speech, fn speech ->
        {:ok, fetched} = StarkInfra.AiSpeech.get(speech.id)

        assert fetched.id == speech.id
        assert fetched.audio != "" and is_binary(fetched.audio)
      end)
    end

    test "get with expand returns the voice name", %{finished_speech: finished_speech} do
      with_finished_speech(finished_speech, fn speech ->
        fetched = StarkInfra.AiSpeech.get!(speech.id, fields: [:id, :voice_name], expand: [:voice_name])

        assert is_binary(fetched.voice_name) and fetched.voice_name != ""
      end)
    end

    test "get unknown id returns input errors" do
      assert_input_errors(StarkInfra.AiSpeech.get("0000000000000000"))
    end
  end

  describe "AiTranscript" do
    test "query" do
      for transcript <- StarkInfra.AiTranscript.query!() do
        assert is_binary(transcript.id)
        assert transcript.status in ["processing", "success", "failed"]
        assert %DateTime{} = transcript.created
      end
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

      expanded = StarkInfra.AiAgent.get!(agent.id, expand: [:knowledge_bases])
      assert [%StarkInfra.AiKnowledgeBase{id: id}] = expanded.knowledge_bases
      assert id == knowledge_base.id
    end

    test "query with fields", %{agent: agent} do
      found = StarkInfra.AiAgent.query!(fields: [:id, :name]) |> Enum.find(fn entity -> entity.id == agent.id end)

      assert found.name == agent.name
      assert is_nil(found.model)
    end

    test "update with only a name keeps the knowledge bases and the schema", %{knowledge_base: knowledge_base} do
      agent = StarkInfra.AiAgent.create!(Fixture.example_ai_agent([knowledge_base.id]))

      try do
        {:ok, renamed} = StarkInfra.AiAgent.update(agent.id, name: "renamed-by-sdk")

        assert renamed.name == "renamed-by-sdk"
        assert renamed.knowledge_base_ids == [knowledge_base.id]
        assert renamed.metadata_schema |> Map.keys() |> Enum.sort() == ["isUrgent", "order_id"]
      after
        StarkInfra.AiAgent.delete!([agent.id])
      end
    end

    test "update with an empty list clears the knowledge bases", %{knowledge_base: knowledge_base} do
      agent = StarkInfra.AiAgent.create!(Fixture.example_ai_agent([knowledge_base.id]))

      try do
        {:ok, cleared} = StarkInfra.AiAgent.update(agent.id, knowledge_base_ids: [])

        assert cleared.knowledge_base_ids == []
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
      assert_input_errors(StarkInfra.AiAgent.create(%StarkInfra.AiAgent{name: "invalid", model: "gpt"}))
    end

    test "get unknown id returns input errors" do
      assert_input_errors(StarkInfra.AiAgent.get("0000000000000000"))
    end
  end

  describe "AiChat" do
    test "create returns the chat", %{chat: chat, agent: agent} do
      assert is_binary(chat.id)
      assert chat.agent_id == agent.id
    end

    test "get, and get with expand returns the agent name", %{chat: chat, agent: agent} do
      assert is_nil(StarkInfra.AiChat.get!(chat.id).agent_name)
      assert StarkInfra.AiChat.get!(chat.id, expand: [:agent_name]).agent_name == agent.name
    end

    test "query", %{chat: chat} do
      assert chat.id in (StarkInfra.AiChat.query!() |> Enum.map(& &1.id))
    end

    test "update changes only the title", %{chat: chat} do
      try do
        {:ok, updated} = StarkInfra.AiChat.update(chat.id, title: "renamed-by-sdk")

        assert updated.title == "renamed-by-sdk"
        assert updated.agent_id == chat.agent_id
      after
        StarkInfra.AiChat.update!(chat.id, title: chat.title)
      end
    end

    test "delete returns the deleted chats", %{agent: agent} do
      chat = StarkInfra.AiChat.create!(%StarkInfra.AiChat{agent_id: agent.id, title: "sdk-elixir-delete"})

      {:ok, deleted} = StarkInfra.AiChat.delete([chat.id])

      assert Enum.map(deleted, & &1.id) == [chat.id]
    end

    test "create with an unknown agent returns input errors" do
      assert_input_errors(StarkInfra.AiChat.create(%StarkInfra.AiChat{agent_id: "0000000000000000"}))
    end

    test "get unknown id returns input errors" do
      assert_input_errors(StarkInfra.AiChat.get("0000000000000000"))
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

    # whether the model fills a field is up to the model; the key spelling is checked at the http boundary
    test "the answer carries a metadata map", %{posted: [_user_message, answer]} do
      assert is_map(answer.metadata)
    end

    test "query returns the whole history", %{posted: posted, chat: chat} do
      found = StarkInfra.AiMessage.query!(chat_id: chat.id) |> Enum.to_list()

      assert MapSet.new(found, & &1.id) == MapSet.new(posted, & &1.id)
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

    test "create in an unknown chat returns input errors" do
      assert_input_errors(StarkInfra.AiMessage.create(%StarkInfra.AiMessage{chat_id: "0000000000000000", text: "hi"}))
    end
  end

  # ExUnit cannot skip at runtime, so a workspace without a finished speech reports it and passes without asserting
  defp with_finished_speech(nil, _assertions) do
    IO.puts(:stderr, "the workspace has no finished speech to read")
  end

  defp with_finished_speech(speech, assertions) do
    assertions.(speech)
  end

  defp assert_input_errors({:error, [%StarkInfra.Error{code: code} | _]}) do
    assert is_binary(code)
    assert code not in ["internalServerError", "unknownError"]
  end
end
