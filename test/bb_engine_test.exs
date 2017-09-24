defmodule BBEngineTest do
  use ExUnit.Case
  doctest BBEngine

  test "greets the world" do
    assert BBEngine.hello() == :world
  end
end
