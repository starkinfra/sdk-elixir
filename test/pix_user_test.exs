defmodule StarkInfraTest.PixUser do
  use ExUnit.Case

  @tag :pix_user
  test "get pix user" do
    {:ok, user} = StarkInfra.PixUser.get("012.345.678-90")
    assert !is_nil(user.id)
    assert is_list(user.statistics)
    Enum.each(user.statistics, fn statistic ->
      assert %StarkInfra.PixUser.Statistics{} = statistic
    end)
  end

  @tag :pix_user
  test "get! pix user" do
    user = StarkInfra.PixUser.get!("012.345.678-90")
    assert !is_nil(user.id)
    assert is_list(user.statistics)
  end

  @tag :pix_user
  test "get! pix user with key id" do
    user = StarkInfra.PixUser.get!("012.345.678-90", key_id: "+5511989898989")
    assert !is_nil(user.id)
  end
end
