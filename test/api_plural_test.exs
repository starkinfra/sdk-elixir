defmodule StarkInfraTestAPIPlural do
  alias StarkInfra.Utils.API
  use ExUnit.Case

  test "Should pluralize a name ending in s unchanged" do
    assert API.last_name_plural("Address") == "address"
  end

  test "Should pluralize a name ending in y as ies" do
    assert API.last_name_plural("Entity") == "entities"
  end

  test "Should pluralize a name ending in ey as eys" do
    assert API.last_name_plural("PixKey") == "keys"
  end

  test "Should pluralize a regular name with s" do
    assert API.last_name_plural("TransferLog") == "logs"
  end

  test "Should pluralize a name ending in ch as ches" do
    assert API.last_name_plural("AiSpeech") == "speeches"
    assert API.last_name_plural("Match") == "matches"
  end

  test "Should pluralize a name ending in sh as shes" do
    assert API.last_name_plural("Dash") == "dashes"
  end

  test "Should pluralize a name ending in x as xes" do
    assert API.last_name_plural("Box") == "boxes"
  end
end
