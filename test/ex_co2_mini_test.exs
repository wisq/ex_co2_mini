defmodule ExCo2MiniTest do
  use ExUnit.Case
  doctest ExCo2Mini

  test "greets the world" do
    assert ExCo2Mini.hello() == :world
  end
end
