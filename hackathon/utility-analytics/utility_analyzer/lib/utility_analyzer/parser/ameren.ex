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
    dollar: ~r/.*\$([0-9]{1,}\.[0-9]{1,2})/
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
    valid_str_list
    |> Enum.each(fn x ->
      Logger.warn inspect x
    end)
    extract(valid_str_list)
    :ok
  end

  def extract(lst) do
    data =
      lst
      |> Enum.reduce([data: %UtilityData{}, lst: lst], fn x, acc ->
        match(acc, x)
        # [data: match(acc[:data], x), lst: acc[:lst] -- [x]]
      end)
    Logger.warn inspect data
    :ok
  end

  def match(utility_data, "Current Charge Detail for Statement" <> date_plus_total = item) do
    date = run_regex(:date, date_plus_total)
    %{utility_data[:data] | date: date}
    transform(utility_data, item)
  end
  def match(utility_data, "Due Date:" <> due_date = item) do
    due_date = run_regex(:date, due_date)
    %{utility_data[:data] | due_date: due_date}
    transform(utility_data, item)
  end
  def match(utility_data, "Previous Statement" <> prev_stmt = item) do
    prev_stmt = run_regex(:dollar, prev_stmt)
    %{utility_data[:data] | prev_amount: prev_stmt}
    transform(utility_data, item)
  end
  def match(utility_data, "Amount Due" <> due_amt = item) do
    due_amt = run_regex(:dollar, due_amt)
    %{utility_data[:data] | amount: due_amt}
    transform(utility_data, item)
  end
  def match(utility_data, _) do
    utility_data
  end

  def transform(utility_data, item) do
    %{data: utility_data[:data], lst: utility_data[:lst] -- [item]}
  end

  @doc """
  Runs regex for given field in given string
  returns match when one is found otherwise nil
  """
  def run_regex(field, haystack) do
    case Regex.run(@re[field], haystack) do
      [_ | [match]] ->
        match
      _ ->
        nil
    end
  end
end
