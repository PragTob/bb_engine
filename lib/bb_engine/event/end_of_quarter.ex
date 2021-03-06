defmodule BBEngine.Event.EndOfQuarter do
  alias BBEngine.{BoxScore, GameState}

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
    %GameState{
      game_state
      | ball_handler_id: nil,
        box_score: BoxScore.advance_quarter(game_state.box_score)
    }
  end
end
