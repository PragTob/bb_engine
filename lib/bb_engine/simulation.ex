defmodule BBEngine.Simulation do
  alias BBEngine.{GameState, Action, Random, Event, BoxScore, Squad}

  @spec new(Squad.t(), Squad.t(), Random.state()) :: GameState.t()
  def new(home_squad, road_squad, seed \\ Random.seed()) do
    # home court advantage?
    home_squad
    |> GameState.new(road_squad, seed)
    |> jump_ball
  end

  @spec simulate(Squad.t(), Squad.t(), Random.state()) :: GameState.t()
  def simulate(home_squad, road_squad, seed \\ Random.seed()) do
    home_squad
    |> new(road_squad, seed)
    |> proceed_simulation
  end

  defp jump_ball(game_state) do
    # of course get a correct jumpball going here
    {new_game_state, winner} = Random.list_element(game_state, game_state.home.lineup)
    %GameState{new_game_state | ball_handler_id: winner, possession: :home}
  end

  @final_quarter 4
  @spec proceed_simulation(GameState.t()) :: GameState.t()
  def proceed_simulation({:done, game_state}) do
    game_state
  end

  def proceed_simulation(game_state) do
    game_state
    |> simulate_event
    |> proceed_simulation
  end

  @spec simulate_event(GameState.t()) :: GameState.t() | {:done, GameState.t()}
  def simulate_event(game_state = %GameState{quarter: quarter, clock_seconds: clock_seconds})
      when clock_seconds <= 0 do
    # Do substitutions etc.
    if finished?(game_state) do
      {:done, game_state}
    else
      new_quarter = quarter + 1
      %GameState{game_state | quarter: new_quarter, clock_seconds: quarter_seconds(new_quarter)}
    end
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

  defp finished?(game_state) do
    game_state.quarter >= @final_quarter && !BoxScore.tie?(game_state.box_score)
  end

  @seconds_per_quarter GameState.seconds_per_quarter()
  @seconds_per_overtime 5 * 60
  defp quarter_seconds(quarter) when quarter <= @final_quarter, do: @seconds_per_quarter
  defp quarter_seconds(_quarter), do: @seconds_per_overtime

  @spec next_action(GameState.t()) :: {GameState.t(), module}
  defp next_action(game_state = %GameState{events: []}) do
    # should be jump ball
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
  # not technically correct, no possession switch if the quarter clock runs out
  defp reaction_action(%Event.Turnover{}), do: Action.SwitchPossession
  defp reaction_action(%Event.Shot{success: false}), do: Action.Rebound
  defp reaction_action(_), do: nil

  @time_critical 8
  defp determine_action(gs = %GameState{clock_seconds: clock_seconds, shot_clock: shot_clock})
       when clock_seconds <= @time_critical or shot_clock <= @time_critical do
    {gs, Action.Forced}
  end

  @pass_shot_distribution 4
  defp determine_action(game_state) do
    # Obviously needs to get more sophisticated
    {game_state, rand} = Random.uniform(game_state, @pass_shot_distribution)

    action =
      if rand < @pass_shot_distribution do
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
  @spec shot_clock_duration(Event.t()) :: non_neg_integer
  defp shot_clock_duration(%Event.Rebound{}), do: 0
  defp shot_clock_duration(%{duration: duration}), do: duration
end
