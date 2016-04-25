defmodule XmlParsingTest do
  use ExUnit.Case
  doctest XmlParsing
  require Record

  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  def sample_xml do
      """
      <html>
        <head>
            <title>XML Parsing Test</title>
        </head>
        <body>
            <p>Neato</p>
            <ul>
                <li>first</li>
                <li>second</li>
                <li>third</li>
            </ul>
        </body>
      </html>
      """
  end

  test "parsing the title out" do
    # Get XML from text
    { xml, _rest} = :xmerl_scan.string(to_char_list(sample_xml))

    # get element in heirarchy
    [element] = :xmerl_xpath.string('/html/head/title', xml)

    # extract content from record map
    [text] = xmlElement(element, :content)

    # get value from content which is an xmlText record map
    value = xmlText(text, :value)

    # cast to string instead of bitstring and inspect
    IO.inspect to_string(value)

    assert value == 'XML Parsing Test'
  end
end
