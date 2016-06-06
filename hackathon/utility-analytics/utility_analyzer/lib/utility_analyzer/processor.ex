defmodule UtilityAnalyzer.Processor do
  @moduledoc """
  A pdf file processing module

  It has functions for pdftotext, imagemagick and tesseract conversion
  as well as file I/O stuffs to be used by the worker process
  """

  @doc """
  Convert native pdf to text
  Uses `-raw flag`. There's `-layout` flag too which maintains the layout.

  Example
  pdftotext("/home/samar/projects/hackr/utility-analytics/pdfs/abc.pdf", "/tmp/abc.txt")
  """
  def pdftotext(infile, outfile \\ "-") do
    Sh.pdftotext "-q", "-raw", infile, outfile
  end

  @doc """
  Run tesseract OCR over the given infile and write to outfile
  """
  def tesseract(infile, outfile) do
    Sh.tesseract infile, outfile
  end

  @doc """
  Extract images from scanned PDFs
  """
  def pdftoimage(_infile, _outfile_prefix) do
    :ok
  end
end
