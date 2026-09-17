defmodule StarkInfraTest.CreditHolmes.Log do
  use ExUnit.Case

  @tag :credit_holmes_log
  test "get credit holmes log" do
    log =
      StarkInfra.CreditHolmes.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkInfra.CreditHolmes.Log.get(log.id)
  end

  @tag :credit_holmes_log
  test "get! credit holmes log" do
    log =
      StarkInfra.CreditHolmes.Log.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    _log = StarkInfra.CreditHolmes.Log.get!(log.id)
  end

  @tag :credit_holmes_log
  test "query credit holmes log" do
    StarkInfra.CreditHolmes.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :credit_holmes_log
  test "query! credit holmes log" do
    StarkInfra.CreditHolmes.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :credit_holmes_log
  test "page credit holmes log" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.CreditHolmes.Log.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :credit_holmes_log
  test "page! credit holmes log" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.CreditHolmes.Log.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
