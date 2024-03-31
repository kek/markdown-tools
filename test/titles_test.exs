defmodule TitlesTest do
  use ExUnit.Case
  doctest Titles

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "convert" do
    test "Converts list of URLs to a Markdown document with links", %{bypass: bypass} do
      input = """
      http://localhost:#{bypass.port}/site1
      http://localhost:#{bypass.port}/site2
      """

      expected = """
      - [Altavista](http://localhost:#{bypass.port}/site1)
      - [Geocities](http://localhost:#{bypass.port}/site2)
      """

      Bypass.expect_once(bypass, "GET", "site1", fn conn ->
        Plug.Conn.resp(conn, 200, ~s(<html><head><title>Altavista</title></head></html>))
      end)

      Bypass.expect_once(bypass, "GET", "site2", fn conn ->
        Plug.Conn.resp(conn, 200, ~s(<html><head><title>Geocities</title></head></html>))
      end)

      assert Titles.convert(input) == expected
    end

    @tag :skip
    test "Ignore stuff that's not URLs"
  end

  describe "compact" do
    test "removes empty lines" do
      input = """
      Hello

      World
      """

      expected = """
      Hello
      World
      """

      assert Titles.compact(input) == expected
    end
  end
end
