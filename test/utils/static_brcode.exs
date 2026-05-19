defmodule StarkInfraTest.Utils.StaticBrcode do
  @moduledoc false

  alias StarkInfra.Utils.Request
  alias StarkInfra.Utils.JSON

  def create_id(key_id) do
    {:ok, body} =
      Request.fetch(
        :post,
        "/static-brcode",
        payload: %{
          brcodes: [
            %{name: "Tony Stark", keyId: key_id, city: "Sao Paulo"}
          ]
        }
      )

    %{"brcodes" => [%{"id" => id} | _]} = JSON.decode!(body)
    id
  end
end
