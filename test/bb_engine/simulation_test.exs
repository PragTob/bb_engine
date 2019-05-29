defmodule BBEngine.SimulationTest do
  use ExUnit.Case
  alias BBEngine.{Event, GameState, Random, BoxScore, TestHelper}
  alias BBEngine.BoxScore.Statistics
  import BBEngine.Simulation

  @home_squad TestHelper.home_squad()
  @road_squad TestHelper.road_squad()

  describe ".simulate" do
    test "simulates a whole game and reaches at least reasonable stats" do
      game_state = simulate(@home_squad, @road_squad)
      %GameState{box_score: box_score} = game_state
      %BoxScore{home: %{team: home}, road: %{team: road}} = box_score

      assert game_state.clock_seconds == 0
      assert game_state.quarter >= 4

      assert game_state.shot_clock >= 0
      assert game_state.shot_clock <= 24

      total_points = home.points + road.points
      assert total_points >= 100
      assert total_points <= 275
      assert home.points != road.points

      assert total_rebounds = home.rebounds + road.rebounds
      assert total_rebounds >= 60

      assert total_offensive_rebounds = home.offensive_rebounds + road.offensive_rebounds
      assert total_offensive_rebounds >= 10

      assert total_turnovers = home.turnovers + road.turnovers
      assert total_turnovers >= 15

      assert total_steals = home.steals + road.steals
      # we're doing kinda too few atm
      assert total_steals >= 1

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

  describe ".run_simulation" do
    test "can safely move on to and simulate overtime" do
      game_state =
        %{clock_seconds: 0, quarter: 4}
        |> TestHelper.build_game_state()
        |> run_simulation()

      # right now one event is simulated
      assert game_state.clock_seconds <= 0
      assert game_state.quarter >= 5
      box_score = game_state.box_score

      total_points = box_score.home.team.points + box_score.road.team.points
      assert total_points >= 6

      assert_stats_add_up(box_score.home)
      assert_stats_add_up(box_score.road)
    end
  end

  describe ".advance_simulation" do
    test "quarters move on" do
      game_state =
        %{clock_seconds: 0, quarter: 2}
        |> TestHelper.build_game_state()
        |> advance_simulation

      # right now one event is simulated
      assert game_state.clock_seconds == 600
      assert game_state.quarter == 3
      assert game_state.shot_clock == 24
    end

    test "we can go to over time" do
      game_state =
        %{clock_seconds: 0, quarter: 4}
        |> TestHelper.build_game_state()
        |> advance_simulation

      # right now one event is simulated
      assert game_state.clock_seconds > 250
      assert game_state.clock_seconds <= 300
      assert game_state.quarter == 5
    end

    test "game ends if scores are different" do
      assert game_state =
               %{clock_seconds: 0, quarter: 4}
               |> TestHelper.build_game_state()
               |> add_home_points
               |> advance_simulation

      assert [%Event.GameFinished{} | _] = game_state.events

      assert game_state.clock_seconds == 0
      assert game_state.quarter == 4
    end

    test "game ends if scores are different also if a forced action occurs" do
      assert game_state =
               %{clock_seconds: 0, quarter: 4}
               |> TestHelper.build_game_state()
               |> add_home_points
               # results in a forced play as no events atm leads to a pass
               |> add_event
               |> advance_simulation

      assert [%Event.GameFinished{} | _] = game_state.events

      assert game_state.clock_seconds == 0
      assert game_state.quarter == 4
    end

    test "if the shot clock is exhaused we create a turnover" do
      game_state =
        %{clock_seconds: 40, quarter: 2, shot_clock: 0}
        |> TestHelper.build_game_state()
        |> advance_simulation

      [last_event | _] = game_state.events

      assert %Event.Turnover{type: :clock_violation} = last_event
    end
  end

  @ball_handler_id 1
  defp add_home_points(game_state) do
    event = %BBEngine.Event.Shot{
      actor_id: @ball_handler_id,
      team: :home,
      success: true,
      duration: 2,
      points: 2
    }

    %GameState{
      game_state
      | box_score:
          BoxScore.update(game_state.box_score, event.team, event.actor_id, fn statistics ->
            %Statistics{
              statistics
              | points: statistics.points + event.points,
                field_goals_attempted: statistics.field_goals_attempted + 1,
                field_goals_made: statistics.field_goals_made + 1,
                two_points_attempted: statistics.two_points_attempted + 1,
                two_points_made: statistics.two_points_made + 1
            }
          end)
    }
  end

  defp add_event(game_state) do
    %GameState{
      game_state
      | events: [%Event.Pass{} | game_state.events]
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
