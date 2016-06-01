defmodule Pdfparser do
  import Pdf2htmlex

  def parse_dir(dir) do
    {:ok, files} = File.ls(dir)
    files
    |>
    Pdfparser.parse    
  end

  def parse(files) when is_list(files) do
    Enum.map(files, fn(x) -> parse(x) end)
  end

  def parse(file) do
    out_file = String.replace_suffix(file, ".pdf", ".html")
    IO.puts "converting #{file} to #{out_file}"
    Path.join('pdfs', file)
    |> open 
    |> externalize_image
    |> externalize_font
    |> hdpi(96)
    |> vdpi(96)
    |> convert_to!(Path.join('html', out_file))
  end
end

Pdfparser.parse_dir("pdfs")