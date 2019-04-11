defmodule BBEngine.Event do
  alias BBEngine.Event
  alias BBEngine.GameState
  alias BBEngine.BoxScore.Statistics

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
          | Event.PossessionSwitch.t()
          | Event.Pass.t()
          | Event.Turnover.t()
          | Event.Steal.t()

  @callback update_game_state(GameState.t(), Event.t()) :: GameState.t()
  @callback update_statistics(Statistics.t(), Event.t()) :: Statistics.t()
end
