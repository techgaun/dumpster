defmodule LeadScrub.CSVReader do
  def read_csv_data(fname) do
    File.stream!(fname) |> CSV.decode
  end
end
