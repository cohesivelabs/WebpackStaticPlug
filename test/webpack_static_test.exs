defmodule WebpackStaticTest do
  @moduledoc false
  use ExUnit.Case
  use Plug.Test
  alias Plug.Conn, as: Conn
  alias WebpackStatic.Plug, as: Plugin

  @opts [
    env: :dev,
    manifest_path: "/manifest.json",
    port: 9000,
    webpack_assets: ~w(js css)
  ]

  @req_body "() => {}"

  setup do
    bypass = Bypass.open(port: @opts[:port])
    {:ok, bypass: bypass}
  end

  test "can serve asset without manifest", %{bypass: bypass} do
    requested_resouce_path = "/js/test.js"

    opts =
      @opts
      |> Keyword.merge(manifest_path: nil)
      |> Plugin.init()

    Bypass.expect_once(bypass, "GET", requested_resouce_path, fn conn ->
      Conn.resp(conn, 200, @req_body)
    end)

    conn =
      conn(:get, requested_resouce_path, nil)
      |> put_req_header("accept", "application/javascript")
      |> Plugin.call(opts)

    assert conn.state == :chunked
    assert conn.status == 200
    assert conn.resp_body == @req_body
    assert conn.halted == true
  end

  test "can serve correct asset when given a manifest", %{bypass: bypass} do
    requested_resouce_path = "/js/test.js"

    opts = Plugin.init(@opts)

    Bypass.expect_once(bypass, "GET", @opts[:manifest_path], fn conn ->
      Conn.resp(conn, 200, ~s<{"js/test.js":"/js/test.1.js"}>)
    end)

    Bypass.expect_once(bypass, "GET", "/js/test.1.js", fn conn ->
      Conn.resp(conn, 200, @req_body)
    end)

    conn =
      conn(:get, requested_resouce_path, nil)
      |> put_req_header("accept", "application/javascript")
      |> Plugin.call(opts)

    assert conn.state == :chunked
    assert conn.status == 200
    assert conn.resp_body == @req_body
    assert conn.halted == true
  end

  test "will not serve file when env is not dev" do
    opts =
      @opts
      |> Keyword.merge(env: :test)
      |> Plugin.init()

    conn =
      conn(:get, "/js/test.js", nil)
      |> put_req_header("accept", "application/javascript")
      |> Plugin.call(opts)

    assert conn.halted == false
    assert conn.state == :unset
    assert conn.status == nil
  end

  test "will raise not found error when manifest request returns a 404", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", @opts[:manifest_path], fn conn ->
      Conn.resp(conn, 404, "{}")
    end)

    opts = Plugin.init(@opts)

    assert_raise RuntimeError,
                 "Error: could not find manifest located at http://localhost:9000/manifest.json",
                 fn ->
                   conn(:get, "/js/test.js", nil)
                   |> put_req_header("accept", "application/javascript")
                   |> Plugin.call(opts)
                 end
  end

  test "will raise generic error when manifest request returns an error code", %{bypass: bypass} do
    opts = Plugin.init(@opts)

    Bypass.expect_once(bypass, "GET", @opts[:manifest_path], fn conn ->
      Conn.resp(conn, 500, "Internal Server Error")
    end)

    assert_raise RuntimeError,
      ~r/^Error: fetching manifest, status:500 body:Internal Server Error/,
        fn ->
          conn(:get, "/js/test.js", nil)
          |> put_req_header("accept", "application/javascript")
          |> Plugin.call(opts)
        end
  end

  test "will raise generic error when manifest request errors", %{bypass: bypass} do
    opts = Plugin.init(@opts)
    Bypass.down(bypass)

    assert_raise RuntimeError,
      ~r/^Error: fetching manifest: econnrefused/, fn ->
        conn(:get, "/js/test.js", nil)
        |> put_req_header("accept", "application/javascript")
        |> Plugin.call(opts)
      end
  end

  test "will pass conn to next plug if webpack asset is not resolved", %{bypass: bypass} do
    requested_resouce_path = "/js/test.js"

    opts =
      @opts
      |> Keyword.merge(manifest_path: nil)
      |> Plugin.init()

    Bypass.expect_once(bypass, "GET", requested_resouce_path, fn conn ->
      Conn.resp(conn, 404, "Not Found")
    end)

    conn =
      conn(:get, requested_resouce_path, nil)
      |> put_req_header("accept", "application/javascript")
      |> Plugin.call(opts)

    assert conn.halted == false
    assert conn.state == :unset
    assert conn.status == nil
  end

  test "will return http status code when an error code is returned from webpack", %{
    bypass: bypass
  } do
    requested_resouce_path = "/js/test.js"

    opts =
      @opts
      |> Keyword.merge(manifest_path: nil)
      |> Plugin.init()

    Bypass.expect_once(bypass, "GET", requested_resouce_path, fn conn ->
      Conn.resp(conn, 500, "Internal Server Error")
    end)

    assert_raise RuntimeError,
      ~r/^Webpack responded with error code: 500/, fn ->
        conn(:get, requested_resouce_path, nil)
        |> put_req_header("accept", "application/javascript")
        |> Plugin.call(opts)
      end
  end

  test "will pass conn to next plug if requested path is not white listed" do
    requested_resouce_path = "/img/test.jpg"

    opts =
      @opts
      |> Keyword.merge(manifest_path: nil)
      |> Plugin.init()

    conn =
      conn(:get, requested_resouce_path, nil)
      |> put_req_header("accept", "application/javascript")
      |> Plugin.call(opts)

    assert conn.halted == false
    assert conn.state == :unset
    assert conn.status == nil
  end

  test "will set resp headers to whatever headers webpack returns", %{bypass: bypass} do
    requested_resouce_path = "/js/test.js"

    opts =
      @opts
      |> Keyword.merge(manifest_path: nil)
      |> Plugin.init()

    Bypass.expect_once(bypass, "GET", requested_resouce_path, fn conn ->
      conn
      |> Conn.put_resp_header("x-test", "I worked")
      |> Conn.resp(200, @req_body)
    end)

    conn =
      conn(:get, requested_resouce_path, nil)
      |> put_req_header("accept", "application/javascript")
      |> Plugin.call(opts)

    assert conn.state == :chunked
    assert conn.status == 200
    assert conn.resp_body == @req_body
    assert conn.halted == true

    [header_value] = Conn.get_resp_header(conn, "x-test")

    assert header_value == "I worked"
  end
end
