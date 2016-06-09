defmodule UtilityAnalyzer.Parser.Ameren do
  @moduledoc """
  Data parser for Ameren's native PDF text

  Uses the data from UtilityAnalyzer.Processor.pdftotext/2
  and creates usable csv from it   
  """

  alias UtilityAnalyzer.UtilityData
  require Logger

  # the module constant below will eventually be a global thing exposed via module
  @re [
    date: ~r/.*([0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}).*/,
    dollar: ~r/.*\$([0-9,]{1,}\.[0-9]{1,2})/,
    numeric: ~r/(\d{1,})/,
    zipcode: ~r/^.*(\d{5}(?:[-\s]\d{4})?)$/,
    meter_readings_block: ~r/^.*Electric\sMeter\sRead(.*)Usage\sSummary.*$/r,
    meter_reading_header: ~r/METER\sNUMBER.*USAGE/r,
    meter_row: ~r/(\d*\.?\d*)\s(\d*\/\d*\s-\s\d*\/\d*)\s(\d*)\s([a-zA-Z0-9_\s]*)\s(Actual)\s(\d*\.?\d*)\s(\d*\.?\d*)\s(\d*\.?\d*)\s(\d*\.?\d*)\s(\d*\.?\d*)\s/,
    usage_summary_block: ~r/^.*Usage\sSummary\s(Total\skWh.*)Rate\s.*$/r,
    usage_summary_item: ~r/.*\s(\d*\.?\d*)?\s/r,
    usage_detail_block: ~r/^.*DESCRIPTION\sUSAGE\sUNIT\sRATE\sCHARGE(.*)Total\sService\sAmount.*$/r,
    usage_detail_item: ~r/(.*)\s([0-9,]{1,}\.?\d*)?\s?(kWh|kW)?\s?@?\s?\$?\s?(\d*\.?\d*)?\s?\$([0-9,]{1,}\.?\d*)\s/r
  ]
  @meter_reading_keys ~w(service_from_to service_period usage_type reading_type current_reading prev_reading reading_diff multiplier usage)
  @usage_detail_keys ~w(usage unit rate charge)

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
    firstpass_data = extract(valid_str_list)
    secondpass_data = regex_extract(firstpass_data[:data], firstpass_data[:lst])
    Logger.warn inspect secondpass_data
    :ok
  end

  def extract(lst) do
    lst
    |> Enum.reduce([data: %UtilityData{}, lst: lst], fn x, acc ->
      match(acc, x)
    end)
  end

  def regex_extract(utility_struct, rem_list) do
    rem_str = rem_list
      |> Enum.join(" ")
    Logger.warn inspect rem_str
    result =
      utility_struct
      |> meter_reading(rem_str)
      |> usage_summary(rem_str)
      |> usage_detail(rem_str)
    result
  end

  @doc """
  Function to extract meter reading whenever possible
  uses meter number as the key
  """
  def meter_reading(utility_struct, str) do
    meter_reading = run_regex(:meter_readings_block, str)
    case meter_reading |> is_nil do
      true ->
        utility_struct
      false ->
        [meter_header] =
          :meter_reading_header
          |> run_multi_regex(meter_reading)
        meter_readings =
          meter_reading
          |> String.replace(meter_header, "")
          |> String.strip
        meter_readings = Regex.scan(@re[:meter_row], meter_readings)
        case meter_readings do
          [] ->
            utility_struct
          matches ->
            meter_readings_map =
              matches
              |> Enum.map(fn match ->
                [h | t] = match
                [meter_num | t] = t
                reading_map =
                  @meter_reading_keys
                  |> Enum.zip(t)
                  |> Enum.into(%{})
                %{meter_num => reading_map}
              end)
            %{utility_struct | meter_readings: meter_readings_map}
        end
    end
  end

  @doc """
  Function to extract usage summary whenever possible
  """
  def usage_summary(utility_struct, str) do
    usage_summary = run_regex(:usage_summary_block, str)
    case usage_summary |> is_nil do
      true ->
        utility_struct
      false ->
        usage_summary_list =
          @re[:usage_summary_item]
          |> Regex.scan(usage_summary)
          |> Enum.map(fn [key, val] ->
            %{String.strip(key) => val}
          end)
        %{utility_struct | usage_summary: usage_summary_list}
    end
  end

  @doc """
  Function to extract usage details whenever possible
  """
  def usage_detail(utility_struct, str) do
    usage_detail = run_regex(:usage_detail_block, str)
    case usage_detail |> is_nil do
      true ->
        utility_struct
      false ->
        usage_detail_list =
          @re[:usage_detail_item]
          |> Regex.scan(usage_detail)
          |> Enum.map(fn [h | t] ->
            [desc | t] = t
            usage_detail_map =
              @usage_detail_keys
              |> Enum.zip(t)
              |> Enum.into(%{})
            %{String.strip(desc) => usage_detail_map}
          end)
        %{utility_struct | usage_details: usage_detail_list}
    end
  end

  @doc """
  Matches and extracts data into struct and reduces list
  the future revisions of the ameren parser should get rid of many of these matches.
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
    # the next line is usually the remaining part of address
    remnant = utility_data[:lst]
      |> Enum.at(find_index(utility_data[:lst], item) + 1)
    zipcode = run_regex(:zipcode, remnant)
    unless zipcode |> is_nil do
      service_address = "#{service_address} #{remnant}"
      utility_data = [data: %{utility_data[:data] | zipcode: zipcode}, lst: utility_data[:lst]]
    end
    (if utility_data[:data].service_address |> is_nil, do: %{utility_data[:data] | service_address: service_address}, else: utility_data[:data])
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
  def match(utility_data, "Rate " <> tariff = item) do
    (if utility_data[:data].tariff |> is_nil, do: %{utility_data[:data] | tariff: tariff}, else: utility_data[:data])
    |> transform(utility_data[:lst], item, true)
  end
  def match(utility_data, "Secondary Srvc " <> secondary_tariff = item) do
    %{utility_data[:data] | secondary_tariff: secondary_tariff}
    |> transform(utility_data[:lst], item)
  end
  def match(utility_data, _) do
    utility_data
  end

  @doc """
  Transform the first pass data structure by reducing list when match is found
  """
  def transform(utility_struct, lst, item, nr \\ false) do
    case nr do
      true ->
        %{data: utility_struct, lst: lst}
      false ->
        %{data: utility_struct, lst: lst -- [item]}
    end
  end

  @doc """
  find index of item in the list
  """
  def find_index(lst, item) do
    lst
    |> Enum.find_index(fn x ->
      x === item
    end)
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

  @doc """
  Runs regex for given field in given string
  returns a list unlike the run_regex which returns single match
  """
  def run_multi_regex(field, haystack) do
    case Regex.run(@re[field], haystack) do
      match ->
        match
        |> Enum.map(fn x ->
          String.strip(x)
        end)
      _ ->
        nil
    end
  end
end
