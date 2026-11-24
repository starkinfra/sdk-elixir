defmodule StarkInfra.CreditNote.TemplateReplacements do
  alias __MODULE__, as: TemplateReplacements

  @moduledoc """
  Groups CreditNote.TemplateReplacements related functions
  """

  @doc """
  The CreditNote.TemplateReplacements struct carries the custom values that fill the placeholders of the
  contract template of a CreditNote. It has no fixed fields: the keys depend on the template.

  Build it with new/1, from a map of placeholder name to value. A plain map is also accepted
  by the `:template_replacements` parameter of StarkInfra.CreditNote and sends the same request.

  Write the keys in snake_case, as atoms or strings: they are sent in camelCase (`guarantor_name` is sent as
  `guarantorName`). Keys with nil values are not sent.

  The struct reads like a map through the Access behaviour, with the keys as they were stored: the string
  keys of a returned CreditNote are the ones sent by the API, in camelCase (`note.template_replacements["guarantorName"]`).

  ## Parameters (optional):
    - `values` [map, default %{}]: placeholder name to value. ex: %{guarantor_name: "Jon Snow", guarantor_tax_id: "012.345.678-90"}
  """
  @behaviour Access

  defstruct []

  @type t() :: %__MODULE__{}

  @spec new(map | keyword) :: t()
  def new(values \\ %{}) do
    Map.merge(%TemplateReplacements{}, Map.new(values))
  end

  @doc false
  def resource_maker(json) when is_map(json) do
    new(json)
  end

  def resource_maker(json) do
    json
  end

  @impl Access
  def fetch(replacements, key) do
    replacements |> Map.from_struct() |> Map.fetch(key)
  end

  @impl Access
  def get_and_update(replacements, key, function) do
    {value, updated} = replacements |> Map.from_struct() |> Map.get_and_update(key, function)
    {value, new(updated)}
  end

  @impl Access
  def pop(replacements, key) do
    {value, rest} = replacements |> Map.from_struct() |> Map.pop(key)
    {value, new(rest)}
  end
end
