defmodule StarkInfraTest.IssuingTokenRequest do
  use ExUnit.Case

  @tag :issuing_token_request
  test "create issuing token request test" do
    cards = StarkInfra.IssuingCard.query!(limit: 1) |> Enum.take(1)
    assert cards != [], "no IssuingCard in sandbox"
    card = cards |> hd

    {:ok, request} =
      StarkInfra.IssuingTokenRequest.create(
        %StarkInfra.IssuingTokenRequest{
          card_id: card.id,
          wallet_id: "google",
          method_code: "app"
        }
      )

    assert !is_nil(request.content)
  end

  @tag :issuing_token_request
  test "create! issuing token request test" do
    cards = StarkInfra.IssuingCard.query!(limit: 1) |> Enum.take(1)
    assert cards != [], "no IssuingCard in sandbox"
    card = cards |> hd

    request =
      StarkInfra.IssuingTokenRequest.create!(
        %StarkInfra.IssuingTokenRequest{
          card_id: card.id,
          wallet_id: "google",
          method_code: "app"
        }
      )

    assert !is_nil(request.content)
  end
end
