defmodule StarkInfraTest.Utils.Random do
    def random_string(length) do
        :crypto.strong_rand_bytes(length)
        |> Base.url_encode64
        |> binary_part(0, length)
    end

    def get_future_datetime(days) do
        DateTime.utc_now
        |> DateTime.add(days*24*60*60, :second)
    end
end
