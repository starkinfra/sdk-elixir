defmodule StarkInfraTest.PixReversal do
  use ExUnit.Case

  @tag :pix_reversal
  test "create pix reversal" do
    {:ok, reversals} = StarkInfra.PixReversal.create([generate_example_pix_reversal()])
    reversal = reversals |> hd

    assert !is_nil(reversal.id)
  end

  @tag :pix_reversal
  test "create! pix reversal" do
    reversal = StarkInfra.PixReversal.create!([generate_example_pix_reversal()]) |> hd
    assert !is_nil(reversal.id)
  end

  @tag :pix_reversal
  test "get pix reversal" do
    pix_reversal = StarkInfra.PixReversal.query!(limit: 100)
      |> Enum.take(1)
      |> hd()

    {:ok, reversal} = StarkInfra.PixReversal.get(pix_reversal.id)
    assert !is_nil(reversal.id)
  end

  @tag :pix_reversal
  test "get! pix reversal" do
    pix_reversal = StarkInfra.PixReversal.query!(limit: 100)
      |> Enum.take(1)
      |> hd

    reversal = StarkInfra.PixReversal.get!(pix_reversal.id)

    assert !is_nil(reversal.id)
  end

  @tag :pix_reversal
  test "query pix reversal" do
    StarkInfra.PixReversal.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_reversal
  test "query! pix reversal" do
    StarkInfra.PixReversal.query!(limit: 101, before: DateTime.utc_now())
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :pix_reversal
  test "page pix reversal" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixReversal.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :pix_reversal
  test "page! pix reversal" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixReversal.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  def get_end_to_end_id_to_reverse(pix_request, cursor \\ nil)

  def get_end_to_end_id_to_reverse(pix_request, cursor) when length(pix_request) == 0 do
    {cursor, requests} = StarkInfra.PixRequest.page!(limit: 10, cursor: cursor, status: ["success"])
    pix_in = Enum.filter(requests, fn(request) -> request.flow == "in" end)
          |> Enum.filter(fn(request) -> request.amount > 10000 end)
          |> Enum.take(1)

    get_end_to_end_id_to_reverse(pix_in, cursor)
  end

  def get_end_to_end_id_to_reverse(pix_request, _cursor) do
    pix_request
  end

  def get_end_to_end_id() do
    pix_request = StarkInfra.PixRequest.query!(limit: 1, status: ["success"]) |> Enum.take(1) |> hd
    pix_request.end_to_end_id
  end

  def generate_example_pix_reversal() do
    pix = get_end_to_end_id_to_reverse([], nil) |> hd
    %StarkInfra.PixReversal{
      amount: Enum.random(1..10),
      end_to_end_id: pix.end_to_end_id,
      external_id: random_string(32),
      reason: "bankError"
    }
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end
