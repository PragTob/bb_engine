defmodule BBEngine.Action.ForcedTest do
  use ExUnit.Case, async: true
  alias BBEngine.TestHelper
  import BBEngine.Action.Forced

  test "doesn't take more time than possible at the end of the game" do
    game_state = TestHelper.build_game_state(%{clock_seconds: 1})

    for i <- 1..10 do
      {game_state, event} = play(game_state)
      assert event.duration <= 1
    end
  end
end
