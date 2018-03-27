defmodule BBEngine.Simulation do
  alias BBEngine.{GameState, Actions, Random, Event, BoxScore, Squad}

  @spec simulate(Squad.t, Squad.t, Random.state) :: GameState.t
  def simulate(home_squad, road_squad, seed \\ Random.seed()) do
    # home court advantage?
    home_squad
    |> GameState.new(road_squad, seed)
    |> jump_ball
    |> proceed_simulation
  end

  defp jump_ball(game_state) do
    # of course get a correct jumpball going here
    {new_game_state, winner} =
      Random.list_element(game_state, game_state.home.lineup)
    %GameState{new_game_state | ball_handler_id: winner, possession: :home}
  end

  @final_quarter 4
  @spec proceed_simulation(GameState.t) :: GameState.t
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
  @spec simulate_event(GameState.t) :: GameState.t
  def simulate_event(game_state = %GameState{quarter: quarter, clock_seconds: clocks_seconds})
         when clocks_seconds <= 0 do
    # Do substitutions etc.
    %GameState{game_state | quarter: quarter + 1,
                             clock_seconds: @seconds_per_quarter}
  end
  def simulate_event(game_state = %GameState{clock_seconds: time}) do
    {new_game_state, event} =
      game_state
      |> determine_action
      |> play_action(game_state)


    %GameState{new_game_state |
      clock_seconds: time - event.duration,
      events: [event | new_game_state.events],
      box_score: BoxScore.update(new_game_state.box_score, event)
    }
  end

  @spec determine_action(GameState.t) :: module
  defp determine_action(%GameState{events: []}) do
    Actions.TwoPointShot
  end
  defp determine_action(%GameState{events: [last_event | _]}) do
    reaction_action(last_event)
  end

  defp reaction_action(%Event.Shot{success: true}) do
    Actions.SwitchPossession
  end
  defp reaction_action(%Event.Shot{success: false}) do
    Actions.Rebound
  end
  defp reaction_action(_) do
    Actions.TwoPointShot
  end

  @spec play_action(module, GameState.t) :: {GameState.t, Event.t}
  defp play_action(action_module, game_state) do
    action_module.play game_state
  end
end
