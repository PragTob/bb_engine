defmodule BBEngine.Event.Steal do
  alias BBEngine.Player
  alias BBEngine.Possession
  alias BBEngine.GameState
  alias BBEngine.BoxScore.Statistics

  @moduledoc """
  These are turnovers committed by individuals by themselves.

  For instance this doesn't count steals as that's a separate event and needs more fields.
  These turnovers are intended to be shot clock violations, stepping out of bounds,
  traveling etc.
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
  def update_game_state(game_state, event) do
    %GameState{
      game_state
      | ball_handler_id: event.actor_id,
        possession: event.team
    }
  end

  @impl true
  def update_statistics(statistics, _event) do
    # TODO: steals (just like blocks) affect the statistics of both attacker and defeder
    # We need to figure out how to incorporate this, either we dispatch on the box score level
    # and let events handle it or we return multiple events (Steal and turnover as well as bloked
    # shot and missed shot but that'd be kinda weird wouldn't it?)
    %Statistics{
      statistics
      | steals: statistics.steals + 1
    }
  end
end
