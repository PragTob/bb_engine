defmodule BBEngine.Simulation do
  alias BBEngine.{GameState, Action, Random, Event, BoxScore, Squad}

  @spec simulate(Squad.t(), Squad.t(), Random.state()) :: GameState.t()
  def simulate(home_squad, road_squad, seed \\ Random.seed()) do
    # home court advantage?
    home_squad
    |> GameState.new(road_squad, seed)
    |> jump_ball
    |> proceed_simulation
  end

  defp jump_ball(game_state) do
    # of course get a correct jumpball going here
    {new_game_state, winner} = Random.list_element(game_state, game_state.home.lineup)
    %GameState{new_game_state | ball_handler_id: winner, possession: :home}
  end

  @final_quarter 4
  @spec proceed_simulation(GameState.t()) :: GameState.t()
  defp proceed_simulation(
         game_state = %GameState{quarter: @final_quarter, clock_seconds: clocks_seconds}
       )
       when clocks_seconds <= 0 do
    game_state
  end

  defp proceed_simulation(game_state) do
    game_state
    |> simulate_event
    |> proceed_simulation
  end

  @seconds_per_quarter GameState.seconds_per_quarter()
  @spec simulate_event(GameState.t()) :: GameState.t()
  def simulate_event(game_state = %GameState{quarter: quarter, clock_seconds: clocks_seconds})
      when clocks_seconds <= 0 do
    # Do substitutions etc.
    %GameState{game_state | quarter: quarter + 1, clock_seconds: @seconds_per_quarter}
  end

  def simulate_event(game_state) do
    {new_game_state, event} =
      game_state
      |> next_action
      |> play_action

    %GameState{
      new_game_state
      | clock_seconds: new_game_state.clock_seconds - event.duration,
        shot_clock: new_game_state.shot_clock - shot_clock_duration(event),
        events: [event | new_game_state.events],
        box_score: BoxScore.update(new_game_state.box_score, event)
    }
  end

  @spec next_action(GameState.t()) :: {GameState.t, module}
  defp next_action(game_state = %GameState{events: []}) do
    {game_state, Action.Pass}
  end

  defp next_action(game_state = %GameState{events: [last_event | _]}) do
    reaction = reaction_action(last_event)
    if reaction do
      {game_state, reaction}
    else
      determine_action(game_state)
    end
  end

  defp reaction_action(%Event.Shot{success: true}), do: Action.SwitchPossession
  defp reaction_action(%Event.Shot{success: false}), do: Action.Rebound
  defp reaction_action(_), do: nil

  defp determine_action(game_state) do
    # Obviously needs to get more sophisticated
    {game_state, rand} = Random.uniform(game_state, 4)
    action = if rand < 4 do
               Action.Pass
             else
              Action.TwoPointShot
             end

    {game_state, action}
  end

  @spec play_action({GameState.t(), module}) :: {GameState.t(), Event.t()}
  defp play_action({game_state, action_module}) do
    action_module.play(game_state)
  end

  # Rebound resets the shot clock and while it takes time from the full clock
  # that duration should not be subtracted from the shot clock as the shot clock
  # gets reset once someone has control of the ball (rebound complete)
  @spec shot_clock_duration(Event.t) :: non_neg_integer
  defp shot_clock_duration(%Event.Rebound{}), do: 0
  defp shot_clock_duration(%{duration: duration}), do: duration
end
