defmodule BBEngine.Simulation do
  alias BBEngine.GameState
  alias BBEngine.Squad
  alias BBEngine.Player
  alias BBEngine.Actions

  def simulate(home_squad, road_squad, seed \\ :rand.seed_s(:exrop)) do
    # home court advantage?
    home_squad
    |> GameState.new(road_squad, seed)
    |> jump_ball
    |> proceed_simulation
  end

  defp jump_ball(game_state) do
    # of course get a correct jumpball going here
    new_ball_handler = Enum.random game_state.home.lineup
    %GameState{game_state | ball_handler_id: new_ball_handler}
  end

  @final_quarter 4
  defp proceed_simulation(game_state = %GameState{quarter: @final_quarter, clock_seconds: clocks_seconds})
         when clocks_seconds <= 0 do
    game_state
  end
  defp proceed_simulation(game_state) do
    game_state
    |> simulate_event
    |> proceed_simulation
  end

  @seconds_per_quarter GameState.seconds_per_quarter()
  def simulate_event(game_state = %GameState{quarter: quarter, clock_seconds: clocks_seconds})
         when clocks_seconds <= 0 do
    # Do substitutions etc.
    %GameState{ game_state | quarter: quarter + 1,
                             clock_seconds: @seconds_per_quarter}
  end
  def simulate_event(game_state = %GameState{clock_seconds: time}) do
    new_game_state = game_state
                     |> determine_action
                     |> play_action(game_state)

    # TBD
    elapsed_time = 10 + :rand.uniform(14)
    %GameState{new_game_state | clock_seconds: time - elapsed_time}
  end

  defp determine_action(_game_state) do
    Actions.TwoPointShot
  end

  defp play_action(action_module, game_state) do
    action_module.play game_state
  end
end
