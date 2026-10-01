defmodule StarkInfra.Utils.AiApi do
  @moduledoc false

  # The AI routes answer under keys the core cannot derive from the resource name (it reads the last word of the
  # name, and "speeches" is not "speechs"), and some creates answer with a list, so the AI resources read the
  # responses themselves through these helpers.

  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Case
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.JSON

  # Only the top-level names are converted: the API answers 400 to any parameter it does not know, and the keys
  # inside values (a metadata schema, a message's metadata) belong to the caller and must reach the API as written.
  def payload(source, creatable_keys) do
    source
    |> Map.take(creatable_keys)
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Map.new(fn {key, value} -> {key |> to_string() |> Case.snake_to_camel(), value} end)
  end

  def fields_and_expand(options) do
    %{
      fields: camel_names(options[:fields]),
      expand: camel_names(options[:expand])
    }
  end

  def single({:ok, response}, key, resource_maker) do
    {:ok, response |> JSON.decode!() |> Map.fetch!(key) |> build(resource_maker)}
  end

  def single({:error, errors}, _key, _resource_maker) do
    {:error, errors}
  end

  def many({:ok, response}, key, resource_maker) do
    {:ok, response |> JSON.decode!() |> Map.fetch!(key) |> build_all(resource_maker)}
  end

  def many({:error, errors}, _key, _resource_maker) do
    {:error, errors}
  end

  def build(json, resource_maker) do
    API.from_api_json(json, resource_maker)
  end

  def build_all(jsons, resource_maker) do
    Enum.map(jsons, fn json -> build(json, resource_maker) end)
  end

  def unwrap!({:ok, result}) do
    result
  end

  def unwrap!({:error, errors}) do
    raise API.errors_to_string(errors)
  end

  # for the routes that answer with every entity at once. fetch_all is a function returning {:ok, list} | {:error, errors}
  def stream(fetch_all) do
    Stream.resource(
      fn -> fetch_all.() end,
      fn
        :done -> {:halt, :done}
        {:ok, entities} -> {Enum.map(entities, &({:ok, &1})), :done}
        {:error, errors} -> {[{:error, errors}], :done}
      end,
      fn _state -> nil end
    )
  end

  def stream!(fetch_all) do
    Stream.resource(
      fn -> fetch_all.() end,
      fn
        :done -> {:halt, :done}
        {:ok, entities} -> {entities, :done}
        {:error, errors} -> raise API.errors_to_string(errors)
      end,
      fn _state -> nil end
    )
  end

  # for the routes that answer a page and a cursor. fetch_page takes (cursor, page_limit) and returns
  # {:ok, {cursor, entities}} | {:error, errors}; limit caps the whole stream, not each page
  def paged_stream(fetch_page, limit) do
    Stream.resource(
      fn -> {:next, nil, limit} end,
      fn state -> next_page(state, fetch_page, &({:ok, &1}), &[{:error, &1}]) end,
      fn _state -> nil end
    )
  end

  def paged_stream!(fetch_page, limit) do
    Stream.resource(
      fn -> {:next, nil, limit} end,
      fn state -> next_page(state, fetch_page, &(&1), &raise(API.errors_to_string(&1))) end,
      fn _state -> nil end
    )
  end

  defp next_page(:done, _fetch_page, _wrap, _on_error) do
    {:halt, :done}
  end

  defp next_page({:next, cursor, remaining}, fetch_page, wrap, on_error) do
    case fetch_page.(cursor, Check.limit(remaining)) do
      {:ok, {next_cursor, entities}} ->
        entities = take(entities, remaining)
        {Enum.map(entities, wrap), following_state(next_cursor, remaining, length(entities))}
      {:error, errors} ->
        {on_error.(errors), :done}
    end
  end

  defp take(entities, nil), do: entities
  defp take(entities, remaining), do: Enum.take(entities, remaining)

  defp following_state(nil, _remaining, _taken), do: :done
  defp following_state(cursor, nil, _taken), do: {:next, cursor, nil}
  defp following_state(_cursor, remaining, taken) when remaining - taken <= 0, do: :done
  defp following_state(cursor, remaining, taken), do: {:next, cursor, remaining - taken}

  defp camel_names(nil), do: nil
  defp camel_names(names), do: Enum.map(names, &(&1 |> to_string() |> Case.snake_to_camel()))
end
