defmodule StarkInfraTest.PixDirector do
  use ExUnit.Case

  @tag :pix_director
  test "create pix director" do
    {:ok, pix_directors} = StarkInfra.PixDirector.create(example_pix_director())
    pix_director = pix_directors |> hd
    assert !is_nil(pix_director.id)
  end

  @tag :pix_director
  test "create! pix director" do
    pix_director = StarkInfra.PixDirector.create!(example_pix_director())
    assert !is_nil(pix_director.id)
  end

  def example_pix_director() do
    %StarkInfra.PixDirector{
      name: "Matheus Ferraz",
      tax_id: "012.345.678-90",
      phone: "+55-1141164616",
      email: "bacen@starkbank.com",
      password: "12345678",
      team_email: "bacen@starkbank.com",
      team_phones: ["+55-1141164616"],
    }
  end
end
