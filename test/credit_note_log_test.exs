defmodule StarkInfraTest.CreditNote.Log do
    use ExUnit.Case

    @tag :credit_note_log
    test "get credit note log" do
        log =
            StarkInfra.CreditNote.Log.query!(limit: 1)
            |> Enum.take(1)
            |> hd()

        {:ok, _log} = StarkInfra.CreditNote.Log.get(log.id)
    end

    @tag :credit_note_log
    test "get! credit note log" do
        log =
            StarkInfra.CreditNote.Log.query!(limit: 1)
            |> Enum.take(1)
            |> hd()

        _log = StarkInfra.CreditNote.Log.get!(log.id)
    end

    @tag :credit_note_log
    test "query credit note log" do
        StarkInfra.CreditNote.Log.query(limit: 101)
        |> Enum.take(200)
        |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :credit_note_log
    test "query! credit note log" do
        StarkInfra.CreditNote.Log.query!(limit: 101)
        |> Enum.take(200)
        |> (fn list -> assert length(list) <= 101 end).()
    end

    @tag :credit_note_log
    test "query! credit note log with filters" do
        note = StarkInfra.CreditNote.query!(status: "created")
        |> Enum.take(1)
        |> hd()

        StarkInfra.CreditNote.Log.query!(limit: 1, note_ids: [note.id], types: "created")
        |> Enum.take(5)
        |> (fn list -> assert length(list) == 1 end).()
    end

    @tag :credit_note_log
    test "page credit note log" do
        {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkInfra.CreditNote.Log.page/1, 2, limit: 5)
        assert length(ids) <= 10
    end

    @tag :credit_note_log
    test "page! credit note log" do
        ids = StarkInfraTest.Utils.Page.get!(&StarkInfra.CreditNote.Log.page!/1, 2, limit: 5)
        assert length(ids) <= 10
    end
end
