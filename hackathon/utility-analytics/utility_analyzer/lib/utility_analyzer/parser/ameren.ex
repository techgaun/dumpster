defmodule UtilityAnalyzer.Parser.Ameren do
  @moduledoc """
  Data parser for Ameren's native PDF text

  Uses the data from UtilityAnalyzer.Processor.pdftotext/2
  and creates usable csv from it   
  """

  def parse(buff) do
    require Logger
    parsed_str_list = buff
      |> String.chunk(:printable)
    valid_str_list =
      parsed_str_list
      |> Enum.filter(fn x ->
        String.printable?(x)
      end)
    valid_str_list
    |> Enum.each(fn x ->
      Logger.error inspect x
    end)
    Logger.warn inspect Enum.count(valid_str_list)
    :ok
  end
end
