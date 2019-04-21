defmodule BBEngine.Event.ThrowIn do
  alias BBEngine.Player
  alias BBEngine.GameState

  defstruct [
    :to_player,
    :duration
  ]

  @type t :: %__MODULE__{
          to_player: Player.id(),
          duration: non_neg_integer
        }

  @behaviour BBEngine.Event
  @impl true
  @spec update_game_state(GameState.t(), t) :: GameState.t()
  def update_game_state(game_state, event) do
    put_in(game_state.ball_handler_id, event.to_player)
  end
end
