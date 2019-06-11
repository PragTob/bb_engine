defmodule BBEngine.Action do
  alias BBEngine.{Event, GameState}

  @type t ::
          Action.BlockedShotRecover
          | Action.Forced
          | Action.FreeThrow
          | Action.Pass
          | Action.Rebound
          | Action.ThreePointShot
          | Action.ThrowIn
          | Action.TwoPointShot
  @doc """
  Simulate the event and return the new game state with the events
  effects applied as well as the event itself for statistics/following
  the game etc.
  """
  @callback play(GameState.t()) :: {GameState.t(), Event.t()}
end
