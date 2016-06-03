defmodule UtilityAnalyzer.Worker do
  use GenServer
  alias UtilityAnalyzer.Processor
  import UtilityAnalyzer.Config
  require Logger

  def start_link(pdf_file) do
    Logger.debug inspect "Starting worker process for #{pdf_file[:name]}"
    Logger.debug inspect pdf_file
    GenServer.start_link(__MODULE__, pdf_file, name: process_ident(pdf_file[:name]))
  end

  def shutdown(pdf_file) do
    GenServer.stop(process_ident(pdf_file), :normal)
  end

  def init(pdf_file) do
    Process.send(self(), :extrparse, [])
    {:ok, pdf_file}
  end

  def handle_info(:extrparse, pdf_file) do
    # outfile = "#{tmp_dir}/#{random_string(20)}.txt"
    pdf_text = Processor.pdftotext(pdf_file[:name])
    Logger.warn inspect pdf_text
    {:stop, :normal, pdf_file}
  end

  @doc """
  Creates random string of given length
  Used for random nonce creation
  """
  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end

  defp process_ident(str) when is_bitstring(str), do: String.replace(str, ~r/(\/|\s|-|\.)/, "_") |> String.strip(?_) |> String.to_atom
end
