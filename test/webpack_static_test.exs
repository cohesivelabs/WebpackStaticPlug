defmodule WebpackStaticTest do
  use ExUnit.Case
  doctest WebpackStatic

  test "greets the world" do
    assert WebpackStatic.hello() == :world
  end
end
