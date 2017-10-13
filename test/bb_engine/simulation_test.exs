defmodule BBEngine.SimulationTest do
  use ExUnit.Case
  alias BBEngine.{GameState, Player, Squad,  Random}
  import BBEngine.Simulation

  @home_squad %Squad{
    players: Enum.map((1..12), fn(id) ->
      %Player{id: id, offensive_rating: 50, defensive_rating: 50}
    end),
    lineup: [1, 2, 3, 4, 5]
  }
  @road_squad %Squad{
    players: Enum.map((13..24), fn(id) ->
      %Player{id: id, offensive_rating: 50, defensive_rating: 50}
    end),
    lineup: [13, 14, 15, 16, 17]
  }

  describe ".simulate" do
    test "simulates a whole game and reaches at least reasonable score" do
      game_state = simulate(@home_squad, @road_squad)
      %GameState{box_score: %{team: team_score}} = game_state

      total_score = team_score.home.points + team_score.road.points
      assert total_score >= 90

      assert game_state.clock_seconds <= 0 # should get fixed :D
      assert game_state.quarter >= 4
    end

    test "simulations are deterministic" do
      seed = Random.seed()
      game_state =  simulate(@home_squad, @road_squad, seed)
      game_state2 = simulate(@home_squad, @road_squad, seed)

      assert game_state == game_state2
    end
  end

  describe ".simulate_event" do
    @ball_handler_id 1
    test "quarters move on" do
      game_state = %{clock_seconds: 0, quarter: 2}
                   |> build_game_state
                   |> simulate_event

      assert game_state.clock_seconds > 550 # right now one event is simulated
      assert game_state.quarter == 3
    end
  end

  defp build_game_state(override) do
    game_state = @home_squad
                 |> GameState.new(@road_squad, :rand.seed_s(:exrop))
                 |> Map.put(:ball_handler_id, @ball_handler_id)

    Map.merge(game_state, override)
  end

end
