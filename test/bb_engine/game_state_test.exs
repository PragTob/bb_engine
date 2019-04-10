defmodule BBEngine.GameStateTest do
  use ExUnit.Case, async: true
  import BBEngine.GameState
  alias BBEngine.GameState
  alias BBEngine.Squad
  alias BBEngine.Player

  describe ".players/2" do
    test "it returns the player structs of the given team" do
      game_state =
        GameState.new(
          %Squad{players: [%Player{id: 1}, %Player{id: 5}], lineup: [1, 5]},
          %Squad{players: [%Player{id: 4}], lineup: [4]}
        )

      assert [%Player{id: 1}, %Player{id: 5}] = players(game_state, :home)
      assert [%Player{id: 4}] = players(game_state, :road)
    end
  end
end
