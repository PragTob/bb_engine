defmodule BBEngine.RandomTest do
  use ExUnit.Case
  import BBEngine.Random

  alias BBEngine.GameState

  describe ".successful?" do
    test "provided the same game state with seed result is the same" do
      game_state = %GameState{current_seed: :rand.seed_s(:exrop)}

      {_gs, first} = successful? game_state, 10, 10
      {_gs, second} = successful? game_state, 10, 10
      {_gs, third} = successful? game_state, 10, 10
      assert first == second
      assert second == third
    end
  end
end
