defmodule TitlesTest do
  use ExUnit.Case
  doctest Titles

  test "Converts list of URLs to a Markdown document with links" do
    input = """
    https://www.google.com/
    https://www.svt.se/
    """

    expected = """
    - [Google](https://www.google.com/)
    - [SVT Nyheter](https://www.svt.se/)
    """

    assert Titles.convert(input) == expected
  end

  @tag :skip
  test "Ignore stuff that's not URLs"
end
