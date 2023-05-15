defmodule StarkInfraTest.CreditHolmes do
  use ExUnit.Case

  @tag :credit_holmes
  test "create credit holmes" do
    {:ok, credit_holmess} = StarkInfra.CreditHolmes.create([example_credit_holmes()])
    credit_holmes = credit_holmess |> hd
    assert !is_nil(credit_holmes.id)
  end

  @tag :credit_holmes
  test "create! credit holmes" do
    credit_holmes = StarkInfra.CreditHolmes.create!([example_credit_holmes()]) |> hd
    assert !is_nil(credit_holmes.id)
  end

  @tag :credit_holmes
  test "get credit holmes" do
    credit_holmes =
      StarkInfra.CreditHolmes.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, holmes} = StarkInfra.CreditHolmes.get(credit_holmes.id)

    assert !is_nil(holmes.id)
  end

  @tag :credit_holmes
  test "get! credit holmes" do
    credit_holmes =
      StarkInfra.CreditHolmes.query!(limit: 1)
      |> Enum.take(1)
      |> hd()
    holmes = StarkInfra.CreditHolmes.get!(credit_holmes.id)

    assert !is_nil(holmes.id)
  end

  @tag :credit_holmes
  test "query credit holmes" do
    StarkInfra.CreditHolmes.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :credit_holmes
  test "query! credit holmes" do
    StarkInfra.CreditHolmes.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :credit_holmes
  test "page credit holmes" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.CreditHolmes.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :credit_holmes
  test "page! credit holmes" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.CreditHolmes.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  def example_credit_holmes() do
    %StarkInfra.CreditHolmes{
      tax_id: "20.018.183/0001-80",
      competence: "2022-08"
    }
  end
end
