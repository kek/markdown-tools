defmodule MarkdownToolsTest do
  use ExUnit.Case
  doctest MarkdownTools

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

      assert MarkdownTools.convert(input) == expected
    end

    test "Ignore stuff that's not URLs", %{bypass: bypass} do
      input = """
      http://localhost:#{bypass.port}/site1
      How about that one?
      http://localhost:#{bypass.port}/site2
      """

      expected = """
      - [Altavista](http://localhost:#{bypass.port}/site1)
      How about that one?
      - [Geocities](http://localhost:#{bypass.port}/site2)
      """

      Bypass.expect_once(bypass, "GET", "site1", fn conn ->
        Plug.Conn.resp(conn, 200, ~s(<html><head><title>Altavista</title></head></html>))
      end)

      Bypass.expect_once(bypass, "GET", "site2", fn conn ->
        Plug.Conn.resp(conn, 200, ~s(<html><head><title>Geocities</title></head></html>))
      end)

      assert MarkdownTools.convert(input) == expected
    end
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

      assert MarkdownTools.compact(input) == expected
    end
  end
end
