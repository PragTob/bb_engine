defmodule BBEngine.Event.Turnover do
  alias BBEngine.Player
  alias BBEngine.Possession
  alias BBEngine.BoxScore.Statistics

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
  def update_game_state(game_state, _event) do
    # noop as the real changes happen in the reaction action possession switch
    # will change when/if we get statistics over
    game_state
  end

  @impl true
  def update_statistics(statistics, _event) do
    %Statistics{
      statistics
      | turnovers: statistics.turnovers + 1
    }
  end
end
