defmodule BBEngine.ActionChooser do
  @moduledoc """
  Depending on current game state/context choose which action shall be performed next.
  """
  alias BBEngine.{Action, BoxScore, Event, GameState, Random}

  @spec next_action(GameState.t()) ::
          {GameState.t(), (GameState.t() -> {GameState.t(), Event.t()})}
  def next_action(game_state) do
    {game_state, action_module} = determine_action(game_state)
    action_function = &action_module.play/1

    {game_state, action_function}
  end

  defp determine_action(game_state = %GameState{events: []}) do
    # should be jump ball
    {game_state, Action.Pass}
  end

  defp determine_action(game_state = %GameState{events: [previous_event | _]}) do
    reaction = reaction_action(previous_event, game_state)

    if reaction do
      {game_state, reaction}
    else
      play_dictated_action(game_state)
    end
  end

  @spec reaction_action(Event.t(), GameState.t()) :: Action.t() | nil
  defp reaction_action(%Event.Shot{success: false}, _), do: Action.Rebound
  defp reaction_action(%Event.Shot{success: true}, _), do: Action.ThrowIn
  defp reaction_action(%Event.Turnover{}, _), do: Action.ThrowIn

  defp reaction_action(%Event.FreeThrow{free_throws_remaining: remaining}, _)
       when remaining >= 1 do
    Action.FreeThrow
  end

  defp reaction_action(%Event.FreeThrow{success: false}, _), do: Action.Rebound
  defp reaction_action(%Event.FreeThrow{success: true}, _), do: Action.ThrowIn

  # look at game state to see if team foul is too high
  defp reaction_action(foul = %Event.Foul{during_shot: false}, game_state) do
    if BoxScore.team_foul_limit_reached?(game_state.box_score, foul.team) do
      Action.FreeThrow
    else
      Action.ThrowIn
    end
  end

  defp reaction_action(%Event.Foul{during_shot: true}, _) do
    Action.FreeThrow
  end

  defp reaction_action(%Event.Block{}, _), do: Action.BlockedShotRecover
  defp reaction_action(%Event.DeflectedOutOfBounds{}, _), do: Action.ThrowIn
  defp reaction_action(%Event.EndOfQuarter{}, _), do: Action.ThrowIn
  defp reaction_action(_, _), do: nil

  @time_critical 8
  defp play_dictated_action(
         gs = %GameState{box_score: %{clock_seconds: clock_seconds, shot_clock: shot_clock}}
       )
       when clock_seconds <= @time_critical or shot_clock <= @time_critical do
    {gs, Action.Forced}
  end

  @action_probability_map %{
    Action.Pass => 75,
    Action.TwoPointShot => 17,
    Action.ThreePointShot => 8
  }
  defp play_dictated_action(game_state) do
    # Obviously needs to get more sophisticated/adaptive to team tactics
    Random.weighted(game_state, @action_probability_map)
  end
end
