defmodule BBEngine.Event.Pass do
  alias BBEngine.Player
  alias BBEngine.Possession

  defstruct [
    :actor_id,
    :receiver_id,
    :duration,
    :team
  ]

  @type t :: %__MODULE__{
          actor_id: Player.id(),
          receiver_id: Player.id(),
          duration: non_neg_integer,
          team: Possession.t()
        }

  @behaviour BBEngine.Event
  @impl true
  def apply(game_state, event) do
    put_in(game_state.ball_handler_id, event.receiver_id)
  end
end
