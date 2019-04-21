defmodule BBEngine.Action.ThrowIn do
  alias BBEngine.GameState
  alias BBEngine.Event
  alias BBEngine.Random

  @behaviour BBEngine.Action

  @impl true
  @spec play(GameState.t()) :: {GameState.t(), Event.ThrowIn.t()}
  def play(game_state) do
    {new_game_state, new_ball_handler} =
      Random.list_element(game_state, GameState.offense_lineup(game_state))

    event = %Event.ThrowIn{
      to_player: new_ball_handler,
      duration: 0
    }

    {new_game_state, event}
  end
end
