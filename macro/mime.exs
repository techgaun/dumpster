defmodule Mime do
  @external_resource mime_path = Path.join(__DIR__, "mimes.txt")

  defmacro __using__(custom_defs) do
    ast =
      for {type, exts} <- custom_defs do
        type = to_string(type)
        quote do
          def exts_from_type(unquote(type)), do: unquote(exts)
          def type_from_ext(ext) when ext in unquote(exts), do: unquote(type)
        end
      end

    quote do
      unquote(ast)
      defdelegate exts_from_type(type), to: Mime
      defdelegate type_from_ext(ext), to: Mime
    end
  end

  for line <- File.stream!(mime_path, [], :line) do
    [type, rest] = line |> String.split("\t") |> Enum.map(&String.strip/1)
    exts = String.split(rest, ~r/,\s?/)

    def exts_from_type(unquote(type)), do: unquote(exts)
    def type_from_ext(ext) when ext in unquote(exts), do: unquote(type)
  end

  def exts_from_type(_), do: []
  def type_from_ext(_), do: nil
  def valid_type?(type), do: exts_from_type(type) |> Enum.any?()
end
