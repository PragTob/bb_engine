defmodule BBEngine.Event.Turnover do
  alias BBEngine.GameState
  alias BBEngine.Player
  alias BBEngine.Possession
  alias BBEngine.BoxScore

  @moduledoc """
  These are turnovers committed by individuals by themselves.

  For instance this doesn't count steals as that's a separate event and needs more fields.
  These turnovers are intended to be shot clock violations, stepping out of bounds,
  traveling etc.
  """

  defstruct [
    :actor_id,
    :team,
    :type,
    duration: 0
  ]

  @type t :: %__MODULE__{
          actor_id: Player.id(),
          team: Possession.t(),
          type: :clock_violation,
          duration: non_neg_integer
        }

  @behaviour BBEngine.Event
  @impl true
  @spec update_game_state(GameState.t(), t) :: GameState.t()
  def update_game_state(game_state, event) do
    %GameState{
      game_state
      | shot_clock: GameState.shot_clock_seconds(),
        box_score:
          BoxScore.update(game_state.box_score, event.team, event.actor_id, fn stats ->
            update_in(stats.turnovers, &(&1 + 1))
          end)
    }
  end
end
