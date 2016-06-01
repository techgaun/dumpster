defmodule Pdfparser do
  import Pdf2htmlex

  def parse(files) when is_list(files) do
    Enum.map(files, fn(x) -> parse(x) end)
  end

  def parse(file) do
    out_file = String.replace_suffix(file, ".pdf", ".html")
    IO.puts "converting #{file} to #{out_file}"
    Path.join('pdfs', file)
    |> open 
    |> zoom(1.5)
    |> hdpi(96)
    |> vdpi(96)
    |> convert_to!(Path.join('html', out_file))
  end
end


["03440-96007.pdf",
"33100-0116.pdf"]
|>
Pdfparser.parse

