defmodule StarkInfraTest.Utils.EndToEndId do
    use ExUnit.Case

    def get_end_to_end_id_to_reverse(pix_request, cursor \\ nil)

    def get_end_to_end_id_to_reverse(pix_request, cursor) when length(pix_request) == 0 do
        {cursor, requests} = StarkInfra.PixRequest.page!(limit: 10, cursor: cursor, status: "success")
        pix_in = Enum.filter(requests, fn(request) -> request.flow == "in" end)
                    |> Enum.filter(fn(request) -> request.amount > 10000 end)
                    |> Enum.take(1)

        get_end_to_end_id_to_reverse(pix_in, cursor)
    end

    def get_end_to_end_id_to_reverse(pix_request, _cursor) do
        pix_request
    end

    def get_end_to_end_id_to_infraction(pix_request, cursor) when length(pix_request) == 0 do
        {cursor, requests} = StarkInfra.PixRequest.page!(limit: 10, cursor: cursor, status: "success")
        pix_in = Enum.filter(requests, fn(request) -> request.flow == "out" end)
                    |> Enum.filter(fn(request) -> request.amount > 10000 end)
                    |> Enum.take(1)

        get_end_to_end_id_to_infraction(pix_in, cursor)
    end

    def get_end_to_end_id_to_infraction(pix_request, _cursor) do
        pix_request
    end

    def get_end_to_end_id() do
        pix_request = StarkInfra.PixRequest.query!(limit: 1, status: "success") |> Enum.take(1) |> hd
        pix_request.end_to_end_id
    end
end
