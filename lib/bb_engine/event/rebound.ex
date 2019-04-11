defmodule BBEngine.Event.Rebound do
  alias BBEngine.Player
  alias BBEngine.Possession
  alias BBEngine.GameState
  alias BBEngine.Event
  alias BBEngine.BoxScore.Statistics

  defstruct [
    :actor_id,
    :duration,
    :team,
    :type
  ]

  @type t :: %__MODULE__{
          actor_id: Player.id(),
          duration: non_neg_integer,
          team: Possession.t(),
          type: :offensive | :defensive
        }

  @behaviour BBEngine.Event
  @impl true
  def update_game_state(game_state, event) do
    %GameState{
      game_state
      | ball_handler_id: event.actor_id,
        possession: event.team,
        shot_clock: shot_clock_seconds(event)
    }
  end

  defp shot_clock_seconds(%__MODULE__{type: :offensive}), do: 14
  defp shot_clock_seconds(_), do: GameState.shot_clock_seconds()

  @impl true
  def update_statistics(statistics, %__MODULE__{type: :defensive}) do
    %Statistics{
      statistics
      | defensive_rebounds: statistics.defensive_rebounds + 1,
        rebounds: statistics.rebounds + 1
    }
  end

  def update_statistics(statistics, %__MODULE__{type: :offensive}) do
    %Statistics{
      statistics
      | offensive_rebounds: statistics.offensive_rebounds + 1,
        rebounds: statistics.rebounds + 1
    }
  end
end
