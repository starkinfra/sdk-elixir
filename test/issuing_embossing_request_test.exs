defmodule StarkInfraTest.IssuingEmbossingRequest do
  use ExUnit.Case

  @tag :issuing_embossing_request
  test "create issuing embossing request" do
    {:ok, requests} = StarkInfra.IssuingEmbossingRequest.create([example_issuing_embossing_request()])
    request = requests |> hd
    assert !is_nil(request.id)
  end

  @tag :issuing_embossing_request
  test "create! issuing embossing request" do
    request = StarkInfra.IssuingEmbossingRequest.create!([example_issuing_embossing_request()]) |> hd
    assert !is_nil(request.id)
  end

  @tag :issuing_embossing_request
  test "get issuing embossing request" do
    request =
      StarkInfra.IssuingEmbossingRequest.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, retrieved_request} = StarkInfra.IssuingEmbossingRequest.get(request.id)
    assert request.id == retrieved_request.id
  end

  @tag :issuing_embossing_request
  test "get! issuing embossing request" do
    request =
      StarkInfra.IssuingEmbossingRequest.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    assert request.id == StarkInfra.IssuingEmbossingRequest.get!(request.id).id
  end

  @tag :issuing_embossing_request
  test "query issuing embossing request" do
    StarkInfra.IssuingEmbossingRequest.query(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_embossing_request
  test "query! issuing embossing request" do
    StarkInfra.IssuingEmbossingRequest.query!(limit: 10)
    |> Enum.take(10)
    |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :issuing_embossing_request
  test "page issuing embossing request" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.IssuingEmbossingRequest.page/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  @tag :issuing_embossing_request
  test "page! issuing embossing request" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.IssuingEmbossingRequest.page!/1, 2, limit: 5)
    assert length(ids) <= 10
  end

  def example_issuing_embossing_request() do
    holder =
      StarkInfra.IssuingHolder.create!([StarkInfraTest.Utils.IssuingHolder.example_issuing_holder()])
      |> hd()

    card =
      StarkInfra.IssuingCard.create!([
        %StarkInfra.IssuingCard{
          holder_name: holder.name,
          holder_tax_id: holder.tax_id,
          holder_external_id: holder.external_id,
          type: "physical",
          display_name: "ANTHONY STARK",
          district: "Bela Vista",
          city: "Sao Paulo",
          state_code: "SP",
          street_line_1: "Av. Paulista, 200",
          street_line_2: "Apto. 123",
          zip_code: "01311-200"
        }
      ])
      |> hd()

    kit =
      StarkInfra.IssuingEmbossingKit.query!(limit: 1)
      |> Enum.take(1)
      |> hd()

    %StarkInfra.IssuingEmbossingRequest{
      card_id: card.id,
      kit_id: kit.id,
      display_name_1: "ANTHONY STARK",
      shipping_city: "SAO PAULO",
      shipping_country_code: "BRA",
      shipping_district: "VILA MADALENA",
      shipping_state_code: "SP",
      shipping_street_line_1: "AVENIDA FARIA LIMA",
      shipping_street_line_2: "Apto. 6",
      shipping_service: "loggi",
      shipping_tracking_number: StarkInfraTest.Utils.Random.random_string(16),
      shipping_zip_code: "05433-000"
    }
  end
end
