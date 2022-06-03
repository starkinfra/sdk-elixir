defmodule StarkInfraTest.IssuingWithdrawal do
  use ExUnit.Case

  @tag :issuing_withdrawal
  test "create issuing withdrawal test" do
    {:ok, issuing_withdrawal} = StarkInfra.IssuingWithdrawal.create(StarkInfraTest.Utils.IssuingWithdrawal.example_issuing_withdrawal())
    {:ok, withdrawal} = StarkInfra.IssuingWithdrawal.get(issuing_withdrawal.id)

    assert issuing_withdrawal.id == withdrawal.id
  end

  @tag :issuing_withdrawal
  test "create! issuing withdrawal test" do
    issuing_withdrawal = StarkInfra.IssuingWithdrawal.create!(StarkInfraTest.Utils.IssuingWithdrawal.example_issuing_withdrawal())
    {:ok, withdrawal} = StarkInfra.IssuingWithdrawal.get(issuing_withdrawal.id)

    assert issuing_withdrawal.id == withdrawal.id
  end

  @tag :issuing_withdrawal
  test "get issuing withdrawal test" do
    withdrawals = StarkInfra.IssuingWithdrawal.query!(limit: 5)
    Enum.each(withdrawals, fn withdrawal ->
      {:ok, issuing_withdrawal} = StarkInfra.IssuingWithdrawal.get(withdrawal.id)
      assert withdrawal.id == issuing_withdrawal.id
    end)
  end

  @tag :issuing_withdrawal
  test "get! issuing withdrawal test" do
    withdrawals = StarkInfra.IssuingWithdrawal.query!(limit: 5)
    Enum.each(withdrawals, fn withdrawal ->
      issuing_withdrawal = StarkInfra.IssuingWithdrawal.get!(withdrawal.id)
      assert withdrawal.id == issuing_withdrawal.id
    end)
  end

  @tag :issuing_withdrawal
  test "query issuing withdrawal test" do
    issuing_withdrawals = StarkInfra.IssuingWithdrawal.query(limit: 10)
      |> Enum.take(10)

    Enum.each(issuing_withdrawals, fn withdrawal ->
      {:ok, withdrawal} = withdrawal
      assert withdrawal.id == StarkInfra.IssuingWithdrawal.get!(withdrawal.id).id
    end)

    assert length(issuing_withdrawals) <= 10
  end

  @tag :issuing_withdrawal
  test "query! issuing withdrawal test" do
    issuing_withdrawals = StarkInfra.IssuingWithdrawal.query!(limit: 10)
      |> Enum.take(10)

    Enum.each(issuing_withdrawals, fn withdrawal ->
      assert withdrawal.id == StarkInfra.IssuingWithdrawal.get!(withdrawal.id).id
    end)

    assert length(issuing_withdrawals) <= 10
  end

  @tag :issuing_withdrawal
  test "page issuing withdrawal test" do
    {:ok, {_cursor, issuing_withdrawals}} = StarkInfra.IssuingWithdrawal.page(limit: 10)

    assert length(issuing_withdrawals) <= 10

    Enum.each(issuing_withdrawals, fn withdrawal ->
      assert withdrawal.id == StarkInfra.IssuingWithdrawal.get!(withdrawal.id).id
    end)
  end

  @tag :issuing_withdrawal
  test "page! issuing withdrawal test" do
    {_cursor, issuing_withdrawals} = StarkInfra.IssuingWithdrawal.page!(limit: 10)

    assert length(issuing_withdrawals) <= 10

    Enum.each(issuing_withdrawals, fn withdrawal ->
      assert withdrawal.id == StarkInfra.IssuingWithdrawal.get!(withdrawal.id).id
    end)
  end
end
