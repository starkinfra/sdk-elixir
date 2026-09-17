defmodule StarkInfraTest.PixKeyHolmes do
  use ExUnit.Case

  @tag :pix_key_holmes
  test "create pix key holmes" do
    {:ok, holmes} = StarkInfra.PixKeyHolmes.create([StarkInfraTest.Utils.PixKeyHolmes.generate_example_pix_key_holmes()])
    pix_key_holmes = holmes |> hd
    assert !is_nil(pix_key_holmes.id)
  end

  @tag :pix_key_holmes
  test "create! pix key holmes" do
    pix_key_holmes = StarkInfra.PixKeyHolmes.create!([StarkInfraTest.Utils.PixKeyHolmes.generate_example_pix_key_holmes()]) |> hd
    assert !is_nil(pix_key_holmes.id)
  end

  @tag :pix_key_holmes
  test "get pix key holmes" do
    pix_key_holmes =
      StarkInfra.PixKeyHolmes.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, holmes} = StarkInfra.PixKeyHolmes.get(pix_key_holmes.id)

    assert !is_nil(holmes.id)
  end

  @tag :pix_key_holmes
  test "get! pix key holmes" do
    pix_key_holmes =
      StarkInfra.PixKeyHolmes.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    holmes = StarkInfra.PixKeyHolmes.get!(pix_key_holmes.id)

    assert !is_nil(holmes.id)
  end

  @tag :pix_key_holmes
  test "query pix key holmes" do
    StarkInfra.PixKeyHolmes.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_key_holmes
  test "query! pix key holmes" do
    StarkInfra.PixKeyHolmes.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_key_holmes
  test "page pix key holmes" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixKeyHolmes.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_key_holmes
  test "page! pix key holmes" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixKeyHolmes.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end
end
