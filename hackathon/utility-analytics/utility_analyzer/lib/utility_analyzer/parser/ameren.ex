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
    parsed_str_list
    |> Enum.each(fn x ->
      Logger.warn inspect x
    end)
    Logger.warn inspect Enum.count(parsed_str_list)
    :ok
  end
end
