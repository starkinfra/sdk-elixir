defmodule StarkInfraTest.PixStatement do
    use ExUnit.Case

    @tag :pix_statement
    test "create pix statement" do
        {:ok, pix_statement} = StarkInfra.PixStatement.create(example_pix_statement())

        assert !is_nil(pix_statement.id)
    end

    @tag :pix_statement
    test "create! pix statement" do
        pix_statement = StarkInfra.PixStatement.create!(example_pix_statement())

        assert !is_nil(pix_statement.id)
    end

    @tag :pix_statement
    test "get pix statement" do
        {:ok, pix} = StarkInfra.PixStatement.query(limit: 10)
            |> Enum.take(1)
            |> hd

        {:ok, pix_statement} = StarkInfra.PixStatement.get(pix.id)
        assert !is_nil(pix_statement.id)
    end

    @tag :pix_statement
    test "get! pix statement" do
        {:ok, pix} = StarkInfra.PixStatement.query(limit: 10)
            |> Enum.take(1)
            |> hd

        pix_statement = StarkInfra.PixStatement.get!(pix.id)
        assert !is_nil(pix_statement.id)
    end

    @tag :pix_statement
    test "query pix statement" do
        StarkInfra.PixStatement.query(limit: 10)
            |> Enum.take(10)
            |> (fn list -> assert length(list) <= 10 end).()
    end

    @tag :pix_statement
    test "query! pix statement" do
        StarkInfra.PixStatement.query!(limit: 10)
            |> Enum.take(200)
            |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :pix_statement
    test "page pix statement" do
        {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.PixStatement.page/1, 2, limit: 5)
        assert length(ids) <= 10
    end

    @tag :pix_statement
    test "page! pix statement" do
        ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.PixStatement.page!/1, 2, limit: 5)
        assert length(ids) <= 10
    end

    @tag :pix_statement
    test "csv pix statement" do
        pix_statements = StarkInfra.PixStatement.query!(limit: 10)
        pix = pix_statements |> Enum.take(1) |> hd

        {:ok, csv} = StarkInfra.PixStatement.csv(pix.id)

        file = File.open!("./statement.zip", [:write])
        IO.binwrite(file, csv)
        File.close(file)

        assert length(csv) > 0
    end

    @tag :pix_statement
    test "csv! pix statement" do
        pix_statements = StarkInfra.PixStatement.query!(limit: 10)
        pix = pix_statements |> Enum.take(1) |> hd

        csv = StarkInfra.PixStatement.csv!(pix.id)

        file = File.open!("./statement1.zip", [:write])
        IO.binwrite(file, csv)
        File.close(file)

        assert length(csv) > 0
    end

    def example_pix_statement() do
        %StarkInfra.PixStatement{
            after: "2021-10-01",
            before: "2021-10-01",
            type: "transaction",
        }
    end
end
