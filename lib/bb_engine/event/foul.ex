defmodule BBEngine.Event.Foul do
  alias BBEngine.Player
  alias BBEngine.Possession
  alias BBEngine.GameState
  alias BBEngine.BoxScore

  @moduledoc """
  Personal Fouls as they occur so often.
  """

  defstruct [
    :actor_id,
    :fouled_player_id,
    :team,
    :during_shot,
    :duration
  ]

  @type t :: %__MODULE__{
          actor_id: Player.id(),
          fouled_player_id: Player.id(),
          team: Possession.t(),
          during_shot: bool(),
          duration: non_neg_integer
        }

  @behaviour BBEngine.Event
  @impl true
  @spec update_game_state(GameState.t(), t) :: GameState.t()
  def update_game_state(game_state, event) do
    %GameState{
      game_state
      | ball_handler_id: event.fouled_player_id,
        possession: Possession.opposite(event.team),
        box_score: update_box_score(game_state.box_score, event)
    }
  end

  defp update_box_score(box_score, event) do
    BoxScore.update(box_score, event.team, event.actor_id, fn statistics ->
      update_in(statistics.fouls, &(&1 + 1))
    end)
  end
end
