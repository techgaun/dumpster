defmodule SalesforceData.Parser do
    import Ecto.Query, only: [from: 2]
    alias SalesforceData.Repo

    def parse_data do
        files = [
                    # {"accounts.csv", SalesforceData.Account, %{sfid: "ID", sfname: "NAME"}}, 
                    # {"buildings.csv", SalesforceData.Building, %{sfid: "ID", sfname: "NAME"}},
                    # {"opportunities.csv", SalesforceData.Opportunity, %{sfid: "ID", sfname: "NAME"}},
                    # {"products.csv", SalesforceData.Product, %{sfid: "ID", sfname: "NAME"}},
                    # 
                    {"3M.csv", SalesforceData.ThreeM, %{sfid: "Acct Number", sfname: "Cust Name"}}
                ]
        parse_data(files)
    end

    def parse_data([]), do: IO.puts "----- End ----"
    def parse_data([{filename, model, col_names} | t]) do
        IO.puts "\n\nInserting data for " <> filename

        accounts_path = Path.join(Application.get_env(:salesforce_data, :src_dir), filename)

        accounts_path
        |> File.read!
        |> String.chunk(:printable)
        |> Enum.filter(fn x -> String.printable?(x) end)
        |> Enum.join("")
        |> ExCsv.parse(headings: true)
        |> parse(col_names, model)

        parse_data(t)
    end

    def parse({:ok, %{body: rows, headings: headings}}, %{sfid: id_col_name, sfname: name_col_name}, model) do
        id_col = Enum.find_index(headings, fn x -> x == id_col_name end)
        name_col = Enum.find_index(headings, fn x -> x == name_col_name end)
        
        insert_rows(rows, headings, id_col, name_col, model, 0)
    end

    def insert_rows([], _headings, _id_col, _name_col, _model, count), do: IO.puts "\nInserted or updated " <> to_string(count) <> " rows."
    def insert_rows([row | rest], headings, id_col, name_col, model, count) do
        if rem(count, 10) == 0 do
            if rem(count, 100) == 0 do
                IO.write to_string(count)
            else
                IO.write "."
            end
        end

        map = %{sfid: Enum.at(row, id_col), name: Enum.at(row, name_col), sfdata: create_key_value_pairs(row, headings, %{})}
        insert(map, model)

        insert_rows(rest, headings, id_col, name_col, model, count + 1)
    end
    def insert(%{sfid: id} = map, model) do
        query = from a in model,
                where: a.sfid == ^id,
                select: a,
                limit: 1

        existing = Repo.one(query)

        changeset =
            case existing do
                nil -> Ecto.Changeset.cast(model.__struct__, map, [:sfid, :name, :sfdata], [])
                existing -> Ecto.Changeset.cast(existing, map, [:sfid, :name, :sfdata], [])
            end

        Repo.insert_or_update(changeset)
    end

    def create_key_value_pairs([], [], map), do: map
    def create_key_value_pairs([val | v_rest], [heading | h_rest], map) do
        create_key_value_pairs(v_rest, h_rest, Map.put(map, heading, val))
    end
end