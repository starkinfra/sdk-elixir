defmodule StarkInfraTest.Utils.AiKnowledgeBase do

  def example_ai_knowledge_base do
    %StarkInfra.AiKnowledgeBase{
      name: "sdk-elixir-#{:crypto.strong_rand_bytes(6) |> Base.encode16(case: :lower)}",
      root_url: "https://docs.starkinfra.com",
      is_recursive: false,
      tags: ["sdk-elixir", "test"]
    }
  end
end
