defmodule StarkInfraTest.CreditNoteTemplateReplacements do
  use ExUnit.Case

  alias StarkInfra.CreditNote
  alias StarkInfra.CreditNote.TemplateReplacements
  alias StarkInfra.Utils.API

  @replacements %{
    "guarantorName" => "Jon Snow",
    "guarantorTaxId" => "012.345.678-90",
    "guarantorAddress" => "Av. Paulista, 200 - Bela Vista - Sao Paulo, SP"
  }

  test "body carries templateReplacements with keys intact" do
    body = build_body(%{template_replacements: @replacements})

    assert body["notes"] |> hd() |> Map.fetch!("templateReplacements") == @replacements
  end

  test "body drops nested keys with nil values" do
    body = build_body(%{template_replacements: Map.put(@replacements, "guarantorEmail", nil)})
    sent = body["notes"] |> hd() |> Map.fetch!("templateReplacements")

    assert sent == @replacements
  end

  test "body omits templateReplacements when absent" do
    refute build_body(%{}) |> Map.fetch!("notes") |> hd() |> Map.has_key?("templateReplacements")
  end

  test "snake_case atom keys are sent in camelCase, as a struct and as a plain map" do
    snake = %{guarantor_name: "Jon Snow", guarantor_tax_id: "012.345.678-90", guarantor_address: "Av. Paulista, 200 - Bela Vista - Sao Paulo, SP"}

    from_map = build_body(%{template_replacements: snake})["notes"] |> hd() |> Map.fetch!("templateReplacements")
    from_struct = build_body(%{template_replacements: TemplateReplacements.new(snake)})["notes"] |> hd() |> Map.fetch!("templateReplacements")

    assert from_map == @replacements
    assert from_struct == @replacements
  end

  test "body from a TemplateReplacements struct equals the body from a plain map" do
    from_struct = build_body(%{template_replacements: TemplateReplacements.new(@replacements)})
    from_map = build_body(%{template_replacements: @replacements})

    assert from_struct == from_map
    assert from_struct["notes"] |> hd() |> Map.fetch!("templateReplacements") == @replacements
  end

  test "struct drops nil values and converts underscored keys like a plain map" do
    replacements = TemplateReplacements.new(%{"guarantorEmail" => nil, "guarantor_name" => "Jon Snow"})
    sent = build_body(%{template_replacements: replacements})["notes"] |> hd() |> Map.fetch!("templateReplacements")

    assert sent == %{"guarantorName" => "Jon Snow"}
  end

  test "parse returns a TemplateReplacements struct with the keys sent by the API" do
    note = parse_note(%{"templateReplacements" => @replacements})

    assert %TemplateReplacements{} = note.template_replacements
    assert note.template_replacements["guarantorName"] == "Jon Snow"
    assert Map.from_struct(note.template_replacements) == @replacements
  end

  test "struct supports Access reads, updates and pop" do
    replacements = TemplateReplacements.new(@replacements)

    assert replacements["missing"] == nil
    assert put_in(replacements["guarantorName"], "Arya Stark")["guarantorName"] == "Arya Stark"
    assert {"Jon Snow", rest} = pop_in(replacements["guarantorName"])
    assert %TemplateReplacements{} = rest
    refute Map.has_key?(rest, "guarantorName")
  end

  test "parse leaves template_replacements nil when the API omits it" do
    assert parse_note(%{}).template_replacements == nil
  end

  # Same steps as Rest.post: api_json per note, wrapped in "notes", encoded by Jason
  defp build_body(overrides) do
    note = struct!(CreditNote, Map.merge(base_fields(), overrides))

    %{"notes" => [API.api_json(note)]}
    |> Jason.encode!()
    |> Jason.decode!()
  end

  defp parse_note(extra) do
    %{
      "id" => "5656565656565656",
      "invoices" => [],
      "signers" => [],
      "payment" => %{},
      "paymentType" => "other",
      "created" => "2020-03-10T10:30:00.000000+00:00",
      "updated" => "2020-03-10T10:30:00.000000+00:00"
    }
    |> Map.merge(extra)
    |> API.from_api_json(&CreditNote.resource_maker/1)
  end

  defp base_fields() do
    %{
      template_id: "0123456789101112",
      name: "Jamie Lannister",
      tax_id: "012.345.678-90",
      scheduled: ~D[2030-01-01],
      invoices: [],
      payment: %{},
      signers: [],
      external_id: "offline-test",
      street_line_1: "Av. Paulista, 200",
      street_line_2: "10 andar",
      district: "Bela Vista",
      city: "Sao Paulo",
      state_code: "SP",
      zip_code: "01310-000"
    }
  end
end
