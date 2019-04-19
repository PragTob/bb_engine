defmodule BBEngine.Actions.ForcedTest do
  use ExUnit.Case, async: true
  alias BBEngine.TestHelper
  import BBEngine.Action.Forced

  test "doesn't take more time than possible at the end of the game" do
    game_state = TestHelper.build_game_state(%{clock_seconds: 1})

    Enum.reduce(1..10, game_state, fn _, gs ->
      {gs, event} = play(gs)
      assert event.duration <= 1
      gs
    end)
  end

  test "doesn't take more time than possible with the shot clock running out" do
    game_state = TestHelper.build_game_state(%{clock_seconds: 50, shot_clock: 1})

    Enum.reduce(1..10, game_state, fn _, gs ->
      {gs, event} = play(gs)
      assert event.duration <= 1
      gs
    end)
  end
end
