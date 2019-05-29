defmodule BBEngine.Event.GameFinished do
  alias BBEngine.GameState

  @doc """
  Game ends.
  """

  defstruct [:duration]

  @type t :: %__MODULE__{
          duration: non_neg_integer
        }

  @behaviour BBEngine.Event
  @impl true
  @spec update_game_state(GameState.t(), t) :: GameState.t()
  def update_game_state(game_state, _event) do
    game_state
  end
end
