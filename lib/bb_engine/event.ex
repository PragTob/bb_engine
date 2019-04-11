defmodule BBEngine.Event do
  alias BBEngine.Event

  @moduledoc """
  Gathers all the event types for easy typing.

  New events that concern an individual/include an event of statistical importance
  should at least include the following field:

  actor_id - who did this?
  team - which team was the person on?
  duration - how long did it take?

  Other fields are free to be event specific.
  """

  @type t ::
          Event.Rebound.t()
          | Event.Shot.t()
          | Event.PossessionSwitch.t()
          | Event.Pass.t()
          | Event.Turnover.t()
end
