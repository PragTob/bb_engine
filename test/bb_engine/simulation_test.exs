defmodule BBEngine.SimulationTest do
  use ExUnit.Case
  alias BBEngine.{GameState, Player, Squad}
  import BBEngine.Simulation



  describe ".simulate" do
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

    test "simulates a whole game and reaches at least reasonable score" do
      game_state = simulate(@home_squad, @road_squad)
      %GameState{box_score: %{team: team_score}} = game_state

      total_score = team_score.home.points + team_score.road.points
      assert total_score >= 90

      assert game_state.clock_seconds <= 0 # should get fixed :D
      assert game_state.quarter >= 4
    end
  end
end
