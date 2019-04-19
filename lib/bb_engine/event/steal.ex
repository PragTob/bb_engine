defmodule BBEngine.Event.Steal do
  alias BBEngine.Player
  alias BBEngine.Possession
  alias BBEngine.GameState
  alias BBEngine.BoxScore

  @moduledoc """
  When someone steals the ball you gotta have it.
  """

  defstruct [
    :actor_id,
    :stolen_from,
    :team,
    :duration
  ]

  @type t :: %__MODULE__{
          actor_id: Player.id(),
          stolen_from: Player.id(),
          team: Possession.t(),
          duration: non_neg_integer
        }

  @behaviour BBEngine.Event
  @impl true
  @spec update_game_state(GameState.t(), t) :: GameState.t()
  def update_game_state(game_state, event) do
    %GameState{
      game_state
      | ball_handler_id: event.actor_id,
        possession: event.team,
        box_score: update_box_score(game_state.box_score, event)
    }
  end

  defp update_box_score(box_score, event) do
    opponent = Possession.opposite(event.team)

    box_score
    |> BoxScore.update(event.team, event.actor_id, fn statistics ->
      update_in(statistics.steals, &(&1 + 1))
    end)
    |> BoxScore.update(opponent, event.stolen_from, fn statistics ->
      update_in(statistics.turnovers, &(&1 + 1))
    end)
  end
end
