defmodule StarkInfra.Utils.Case do
  @moduledoc false

  def camel_to_kebab(binary) do
  binary
  |> camel_to_snake()
  |> String.replace("_", "-")
  end

  def camel_to_snake(binary) do
  binary
  |> String.graphemes()
  |> camel_to_snake_graphemes()
  |> strip_underscore()
  |> Enum.join()
  end

  defp camel_to_snake_graphemes([letter | rest]) do
  cond do
    letter == letter |> String.upcase() ->
    ["_" | [String.downcase(letter) | camel_to_snake_graphemes(rest)]]

    :error != Integer.parse(letter) ->
    ["_" | [letter | camel_to_snake_graphemes(rest)]]

    true ->
    [letter | camel_to_snake_graphemes(rest)]
  end
  end

  defp camel_to_snake_graphemes([]) do
  []
  end

  defp strip_underscore([letter | rest]) when letter == "_" do
  rest
  end

  defp strip_underscore(binary) do
  binary
  end

  def snake_to_camel(binary) do
  binary
  |> String.graphemes()
  |> snake_to_camel_graphemes()
  |> Enum.join()
  end

  defp snake_to_camel_graphemes([letter | rest]) when letter == "_" do
  snake_to_camel_graphemes([String.upcase(hd(rest)) | tl(rest)])
  end

  defp snake_to_camel_graphemes([letter | rest]) do
  [letter | snake_to_camel_graphemes(rest)]
  end

  defp snake_to_camel_graphemes([]) do
  []
  end
end
