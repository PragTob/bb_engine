defmodule BBEngine.SimulationTest do
  use ExUnit.Case
  alias BBEngine.{GameState, Player, Squad,  Random, BoxScore}
  import BBEngine.Simulation

  @home_squad %Squad{
    players: Enum.map((1..12), &Player.standard_player/1),
    lineup: [1, 2, 3, 4, 5]
  }
  @road_squad %Squad{
    players: Enum.map((13..24), &Player.standard_player/1),
    lineup: [13, 14, 15, 16, 17]
  }

  describe ".simulate" do
    test "simulates a whole game and reaches at least reasonable stats" do
      game_state = simulate(@home_squad, @road_squad)
      %GameState{box_score: box_score} = game_state
      %BoxScore{home: %{team: home}, road: %{team: road}} = box_score

      total_points = home.points + road.points
      assert total_points >= 100
      assert total_points <= 250

      assert total_rebounds = home.rebounds + road.rebounds
      assert  total_rebounds >= 60

      assert game_state.clock_seconds <= 0 # should get fixed :D
      assert game_state.quarter >= 4

      assert game_state.shot_clock >= 0
      assert game_state.shot_clock <= 24

      assert_stats_add_up(box_score.home)
      assert_stats_add_up(box_score.road)      
    end

    defp assert_stats_add_up(box_score_stats) do
      team_stats = box_score_stats.team
      player_stats = Map.drop(box_score_stats, [:team])

  
      Enum.each(BoxScore.Statistics.stats(), fn stat ->
        assert Map.fetch!(team_stats, stat) == summed_stats(player_stats, stat)
      end)
    end

    defp summed_stats(player_stats, stat) do
      player_stats
      |> Enum.map(fn {_id, stats} -> Map.fetch!(stats, stat) end)
      |> Enum.sum
    end

    test "simulations are deterministic" do
      seed = Random.seed()
      game_state  = simulate(@home_squad, @road_squad, seed)
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
