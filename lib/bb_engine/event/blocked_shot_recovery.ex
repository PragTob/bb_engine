defmodule BBEngine.Event.BlockedShotRecovery do
  alias BBEngine.Player
  alias BBEngine.Possession
  alias BBEngine.GameState
  alias BBEngine.BoxScore

  defstruct [
    :to_team,
    :actor_id,
    :duration,
    :type
  ]

  @type t :: %__MODULE__{
          to_team: Possession.t(),
          actor_id: Player.id(),
          duration: non_neg_integer,
          type: :offensive | :defensive
        }

  @behaviour BBEngine.Event
  @impl true
  @spec update_game_state(GameState.t(), t) :: GameState.t()
  def update_game_state(game_state, event) do
    %GameState{
      game_state
      | ball_handler_id: event.actor_id,
        possession: event.to_team,
        box_score:
          BoxScore.update(game_state.box_score, event.to_team, event.actor_id, fn stats ->
            update_statistics(stats, event)
          end)
    }
  end

  # yes yes recovering blocked shots counts as a rebound yes yes
  defp update_statistics(statistics, %__MODULE__{type: :offensive}) do
    update_in(statistics.offensive_rebounds, &(&1 + 1))
  end

  defp update_statistics(statistics, %__MODULE__{type: :defensive}) do
    update_in(statistics.defensive_rebounds, &(&1 + 1))
  end
end
