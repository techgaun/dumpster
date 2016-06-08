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
    dollar: ~r/.*\$([0-9,]{1,}\.[0-9]{1,2})/,
    numeric: ~r/(\d{1,})/
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
    # valid_str_list
    # |> Enum.each(fn x ->
    #   Logger.warn inspect x
    # end)
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

  @doc """
  Matches and extracts data into struct and reduces list
  """
  def match(utility_data, "Account Number" <> acc_num = item) do
    acc_num = run_regex(:numeric, acc_num)
    %{utility_data[:data] | account_num: acc_num}
    |> transform(utility_data[:lst], item)
  end
  def match(utility_data, "Customer Name " <> cust_name = item) do
    %{utility_data[:data] | customer_name: cust_name}
    |> transform(utility_data[:lst], item)
  end
  def match(utility_data, "Service Address " <> service_address = item) do
    %{utility_data[:data] | service_address: service_address}
    |> transform(utility_data[:lst], item)
  end
  def match(utility_data, "Current Charge Detail for Statement" <> date = item) do
    date = run_regex(:date, date)
    %{utility_data[:data] | statement_date: date}
    |> transform(utility_data[:lst], item)
  end
  def match(utility_data, "Current Detail for Statement" <> date = item) do
    date = run_regex(:date, date)
    %{utility_data[:data] | statement_date: date}
    |> transform(utility_data[:lst], item)
  end
  def match(utility_data, "Due Date" <> due_date = item) do
    due_date = run_regex(:date, due_date)
    %{utility_data[:data] | due_date: due_date}
    |> transform(utility_data[:lst], item)
  end
  def match(utility_data, "Previous Statement" <> prev_stmt = item) do
    prev_stmt = run_regex(:dollar, prev_stmt)
    %{utility_data[:data] | prev_amount: prev_stmt}
    |> transform(utility_data[:lst], item)
  end
  def match(utility_data, "Amount Due" <> due_amt = item) do
    due_amt = run_regex(:dollar, due_amt)
    (if utility_data[:data].amount |> is_nil, do: %{utility_data[:data] | amount: due_amt}, else: utility_data[:data])
    |> transform(utility_data[:lst], item)
  end
  def match(utility_data, "Total Amount Due" <> due_amt = item) do
    due_amt = run_regex(:dollar, due_amt)
    (if utility_data[:data].amount |> is_nil, do: %{utility_data[:data] | amount: due_amt}, else: utility_data[:data])
    |> transform(utility_data[:lst], item)
  end
  def match(utility_data, "Last Payment" <> last_payment_date = item) do
    last_payment_date = run_regex(:date, last_payment_date)
    %{utility_data[:data] | last_payment_date: last_payment_date}
    |> transform(utility_data[:lst], item)
  end
  def match(utility_data, "Delinquent After" <> delinquent_date = item) do
    last_payment_date = run_regex(:date, delinquent_date)
    %{utility_data[:data] | delinquent_date: delinquent_date}
    |> transform(utility_data[:lst], item)
  end
  def match(utility_data, "Amount After Delinquent Date $" <> delinquent_amount = item) do
    delinquent_amount = run_regex(:dollar, "$#{delinquent_amount}")
    %{utility_data[:data] | delinquent_amount: delinquent_amount}
    |> transform(utility_data[:lst], item)
  end
  def match(utility_data, _) do
    utility_data
  end

  def transform(utility_struct, lst, item) do
    %{data: utility_struct, lst: lst -- [item]}
  end

  @doc """
  Runs regex for given field in given string
  returns match when one is found otherwise nil
  """
  def run_regex(field, haystack) do
    case Regex.run(@re[field], haystack) do
      [_ | [match]] ->
        String.strip(match)
      _ ->
        nil
    end
  end
end
