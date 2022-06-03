defmodule StarkInfraTest.PixDomain do
  use ExUnit.Case

  @tag :pix_domain
  test "query pix domain" do
    StarkInfra.PixDomain.query()
      |> Enum.take(1)
      |> (fn certificates -> assert length(certificates) <= 1  end).()
  end

  @tag :pix_domain
  test "query! pix domain" do
    StarkInfra.PixDomain.query!()
      |> Enum.take(1)
      |> (fn certificates -> assert length(certificates) <= 1 end).()
  end
end
