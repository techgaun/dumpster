defmodule Pdfparser do
  import Pdf2htmlex

  def parse do

  end

  def parse(file, out_file) do
    file
    |> open 
    |> zoom(1.5)
    |> hdpi(96)
    |> vdpi(96)
    |> convert_to!(out_file)
  end
end

Pdfparser.parse