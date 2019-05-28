defmodule BBEngine.Event.TimeRanOut do
  alias BBEngine.GameState

  @doc """
  Time of the quarter ran out. Play subsides, no TOs or whatever are handed out.
  """

  defstruct [:duration]

  @type t :: %__MODULE__{
          duration: non_neg_integer
        }

  @behaviour BBEngine.Event
  @impl true
  @spec update_game_state(GameState.t(), t) :: GameState.t()
  def update_game_state(game_state, _event) do
    put_in(game_state.ball_handler_id, nil)
  end
end