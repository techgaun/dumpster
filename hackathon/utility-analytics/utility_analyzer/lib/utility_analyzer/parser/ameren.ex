defmodule UtilityAnalyzer.Parser.Ameren do
  @moduledoc """
  Data parser for Ameren's native PDF text

  Uses the data from UtilityAnalyzer.Processor.pdftotext/2
  and creates usable csv from it   
  """

  alias UtilityAnalyzer.UtilityData
  require Logger

  @re [
    date: ~r/.*([0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}).*/,
    total: ~r/.*AMOUNT DUE.*\$([0-9]{1,}\.[0-9]{1,2})/
  ]

  def parse(buff) do
    parsed_str_list = buff
      |> String.chunk(:printable)
    valid_str_list =
      parsed_str_list
      |> Enum.filter(fn x ->
        String.printable?(x)
      end)
      |> Enum.join
      |> String.split("\n")
      |> Enum.map(fn x ->
        String.strip(x)
      end)
      |> Enum.filter(fn x ->
        String.length(x) > 0
      end)
    # valid_str
    # |> Enum.each(fn x ->
    #   Logger.warn inspect x
    # end)
    extract(valid_str_list)
    :ok
  end

  def extract(lst) do
    data = %UtilityData{}
    lst
    |> Enum.each(fn x ->
      Logger.warn inspect match(data, x)
    end)
    :ok
  end

  def match(utility_data, "Current Charge Detail for Statement" <> date_plus_total) do
    date =
      case Regex.run(@re[:date], date_plus_total) do
        [_ | [match]] ->
          match
        _ ->
          nil
      end
    total =
      case Regex.run(@re[:total], date_plus_total) do
        [_ | [match]] ->
          match
        _ ->
          nil
      end
    Logger.warn inspect utility_data
    Logger.warn inspect {date, total}
  end
  def match(_, _) do
    :ok
  end
end
