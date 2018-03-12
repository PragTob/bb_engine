defmodule BBEngine.RandomTest do
  use ExUnit.Case, async: true
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

  describe ".weighted" do
    test "returns one of the given options" do
      game_state = %GameState{current_seed: :rand.seed_s(:exrop)}
      
      {_gs, result} = weighted game_state, %{"1" => 50, "2" => 50, "3" => 50}
      assert Enum.member?(["1", "2", "3"], result)
    end

    test "with just one value" do
      game_state = %GameState{current_seed: :rand.seed_s(:exrop)}
      
      {_gs, result} = weighted game_state, %{"1" => 50}
      assert result == "1"
    end

    test "about matches up the percentages" do
      game_state = %GameState{current_seed: :rand.seed_s(:exrop)}
      weights = %{"10" => 10, "20" => 20, "30" => 30, "40" => 40}
      
      {_, results} = Enum.reduce((1..1000), {game_state, %{}}, fn _, {gs, acc} ->
        {gs, result} = weighted gs, weights
        {gs, Map.update(acc, result, 1, fn value -> value + 1 end)}
      end)

      assert results["10"] <= results["20"]
      assert results["20"] <= results["30"]
      assert results["30"] <= results["40"]
      assert results["40"] >= 250
    end
  end
end
