defmodule BBEngine.SimulationTest do
  use ExUnit.Case
  alias BBEngine.{GameState, Player, Squad, Random, BoxScore}
  import BBEngine.Simulation

  @home_squad %Squad{
    players: Enum.map(1..12, &Player.standard_player/1),
    lineup: [1, 2, 3, 4, 5]
  }
  @road_squad %Squad{
    players: Enum.map(13..24, &Player.standard_player/1),
    lineup: [13, 14, 15, 16, 17]
  }
  @ball_handler_id 1

  describe ".simulate" do
    test "simulates a whole game and reaches at least reasonable stats" do
      game_state = simulate(@home_squad, @road_squad)
      %GameState{box_score: box_score} = game_state
      %BoxScore{home: %{team: home}, road: %{team: road}} = box_score

      total_points = home.points + road.points
      assert total_points >= 100
      assert total_points <= 250
      assert home.points != road.points

      assert total_rebounds = home.rebounds + road.rebounds
      assert total_rebounds >= 60

      # should get fixed :D
      assert game_state.clock_seconds <= 0
      assert game_state.quarter >= 4

      assert game_state.shot_clock >= 0
      assert game_state.shot_clock <= 24

      assert_stats_add_up(box_score.home)
      assert_stats_add_up(box_score.road)
    end

    test "simulations are deterministic" do
      seed = Random.seed()
      game_state = simulate(@home_squad, @road_squad, seed)
      game_state2 = simulate(@home_squad, @road_squad, seed)

      assert game_state == game_state2
    end
  end

  describe ".proceed_simulation" do
    test "can safely move on to and simulate overtime" do
      game_state =
        %{clock_seconds: 0, quarter: 4}
        |> build_game_state()
        |> proceed_simulation()

      # right now one event is simulated
      assert game_state.clock_seconds <= 0
      assert game_state.quarter >= 5
      box_score = game_state.box_score

      total_points = box_score.home.team.points + box_score.road.team.points
      assert total_points >= 12

      assert_stats_add_up(box_score.home)
      assert_stats_add_up(box_score.road)
    end
  end

  describe ".simulate_event" do
    test "quarters move on" do
      game_state =
        %{clock_seconds: 0, quarter: 2}
        |> build_game_state
        |> simulate_event

      # right now one event is simulated
      assert game_state.clock_seconds > 550
      assert game_state.quarter == 3
    end

    test "we can go to over time" do
      game_state =
        %{clock_seconds: 0, quarter: 4}
        |> build_game_state
        |> simulate_event

      # right now one event is simulated
      assert game_state.clock_seconds > 250
      assert game_state.clock_seconds <= 300
      assert game_state.quarter == 5
    end

    test "game ends if scores are different" do
      assert {:done, game_state} =
               %{clock_seconds: 0, quarter: 4}
               |> build_game_state
               |> add_home_points
               |> simulate_event

      assert game_state.clock_seconds == 0
      assert game_state.quarter == 4
    end
  end

  defp build_game_state(override) do
    game_state =
      @home_squad
      |> GameState.new(@road_squad, Random.seed())
      |> Map.put(:ball_handler_id, @ball_handler_id)
      |> Map.put(:possession, :home)

    Map.merge(game_state, override)
  end

  defp add_home_points(game_state) do
    event = %BBEngine.Event.Shot{
      actor_id: @ball_handler_id,
      team: :home,
      success: true,
      duration: 2
    }

    %GameState{
      game_state
      | box_score: BoxScore.update(game_state.box_score, event)
    }
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
    |> Enum.sum()
  end
end
