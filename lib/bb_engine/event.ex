defmodule BBEngine.Event do
  alias BBEngine.Event
  alias BBEngine.GameState

  @moduledoc """
  Gathers all the event types for easy typing.

  New events that concern an individual/include an event of statistical importance
  should at least include the following field:

  actor_id - who did this?
  team - which team was the person on?
  duration - how long did it take?

  Other fields are free to be event specific.

  Behaviour wise implementors need to implement `update_game_state/2` which is the specific effect that
  this event had on the game state (not including clock etc. but what is directly related
  to this event).
  """

  @type t ::
          Event.Rebound.t()
          | Event.Shot.t()
          | Event.ThrowIn.t()
          | Event.Pass.t()
          | Event.Turnover.t()
          | Event.Steal.t()
          | Event.Block.t()
          | Event.Foul.t()
          | Event.BlockedShotRecovery.t()
          | Event.DeflectedOutOfBounds.t()
          | Event.EndOfQuarter.t()
          | Event.GameFinished.t()

  @callback update_game_state(GameState.t(), Event.t()) :: GameState.t()

  @spec apply(GameState.t(), t) :: GameState.t()
  def apply(game_state, event) do
    game_state
    |> common_event_changes(event)
    |> event_specific_changes(event)
  end

  defp common_event_changes(game_state, event) do
    %GameState{
      game_state
      | clock_seconds: game_state.clock_seconds - event.duration,
        shot_clock: game_state.shot_clock - shot_clock_duration(event),
        events: [event | game_state.events]
    }
  end

  defp event_specific_changes(game_state, event) do
    event.__struct__.update_game_state(game_state, event)
  end

  # Rebound resets the shot clock and while it takes time from the full clock
  # that duration should not be subtracted from the shot clock as the shot clock
  # gets reset once someone has control of the ball (rebound complete)
  @spec shot_clock_duration(Event.t()) :: non_neg_integer
  defp shot_clock_duration(%Event.Rebound{}), do: 0
  defp shot_clock_duration(%{duration: duration}), do: duration
end
