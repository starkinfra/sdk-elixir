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
      # the second key is camelCase on purpose: schema keys are the caller's and must reach the API untouched
      metadata_schema: %{
        "order_id" => %{"type" => "string", "description" => "Order the customer mentions"},
        "isUrgent" => %{"type" => "boolean"}
      }
    }
  end

  # a deletable resource can be refused with a 500 by the sandbox, which is reported instead of swallowed
  def delete_or_warn(module, label, id) do
    case module.delete([id]) do
      {:ok, _deleted} -> :ok
      {:error, [%StarkInfra.Error{code: "internalServerError"} | _]} ->
        IO.puts(:stderr, "#{label} #{id} was not deleted: the API answered 500")
      {:error, errors} -> raise StarkInfra.Utils.API.errors_to_string(errors)
    end
  end
end
