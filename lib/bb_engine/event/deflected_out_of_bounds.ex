defmodule BBEngine.Event.DeflectedOutOfBounds do
  alias BBEngine.Player
  alias BBEngine.GameState

  defstruct [
    :actor_id,
    :duration
  ]

  @type t :: %__MODULE__{
          actor_id: Player.id(),
          duration: non_neg_integer
        }

  @behaviour BBEngine.Event
  @impl true
  @spec update_game_state(GameState.t(), t) :: GameState.t()
  def update_game_state(game_state, event) do
    # An inbounds play follows
    put_in(game_state.ball_handler_id, nil)
  end
end
