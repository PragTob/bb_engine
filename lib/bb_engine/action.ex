defmodule BBEngine.Action do
  alias BBEngine.{Event, GameState}

  @doc """
  Simulate the event and return the new game state with the events
  effects applied as well as the event itself for statistics/following
  the game etc.
  """
  @callback play(GameState.t()) :: {GameState.t(), Event.t()}
end
