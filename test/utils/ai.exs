defmodule StarkInfraTest.Utils.Ai do

  def unique_name(prefix) do
    "#{prefix}-#{:crypto.strong_rand_bytes(6) |> Base.encode16(case: :lower)}"
  end

  def example_ai_agent(knowledge_base_ids \\ nil) do
    %StarkInfra.AiAgent{
      name: unique_name("sdk-elixir-agent"),
      model: "bender-1.0",
      system_prompt: "Answer in one short sentence.",
      knowledge_base_ids: knowledge_base_ids,
      metadata_schema: %{
        "order_id" => %{"type" => "string", "description" => "Order the customer mentions"},
        "isUrgent" => %{"type" => "boolean"}
      }
    }
  end

  def example_ai_chat(agent_id) do
    %StarkInfra.AiChat{
      agent_id: agent_id,
      title: unique_name("sdk-elixir-chat"),
      tags: ["sdk-elixir", unique_name("tag")],
      context: %{"first_name" => "Ana", "isVip" => true}
    }
  end

  def all_pages(page_function, options \\ [], cursor \\ nil, collected \\ []) do
    {:ok, {next_cursor, entities}} = page_function.(Keyword.put(options, :cursor, cursor))
    collected = collected ++ entities
    case next_cursor do
      nil -> collected
      _cursor -> all_pages(page_function, options, next_cursor, collected)
    end
  end
end
