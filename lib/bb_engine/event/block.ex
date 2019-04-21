defmodule BBEngine.Event.Block do
  alias BBEngine.Player
  alias BBEngine.Possession
  alias BBEngine.GameState
  alias BBEngine.BoxScore
  alias BBEngine.BoxScore.Statistics

  @moduledoc """
  NOT IN MY HOUSE!
  """

  defstruct [
    :actor_id,
    :blocked_player_id,
    :team,
    :type,
    :duration
  ]

  @type t :: %__MODULE__{
          actor_id: Player.id(),
          blocked_player_id: Player.id(),
          team: Possession.t(),
          type: :two_point | :three_point,
          duration: non_neg_integer
        }

  @behaviour BBEngine.Event
  @impl true
  @spec update_game_state(GameState.t(), t) :: GameState.t()
  def update_game_state(game_state, event) do
    %GameState{
      game_state
      | box_score: update_box_score(game_state.box_score, event)
    }
  end

  defp update_box_score(box_score, event) do
    opponent = Possession.opposite(event.team)

    box_score
    |> BoxScore.update(event.team, event.actor_id, fn statistics ->
      update_in(statistics.blocks, &(&1 + 1))
    end)
    |> BoxScore.update(opponent, event.blocked_player_id, fn statistics ->
      update_statistics(statistics, event)
    end)
  end

  defp update_statistics(statistics, %__MODULE__{type: :two_point}) do
    %Statistics{
      statistics
      | blocked_shots: statistics.blocked_shots + 1,
        two_points_attempted: statistics.two_points_attempted + 1,
        field_goals_attempted: statistics.field_goals_attempted + 1
    }
  end

  defp update_statistics(statistics, %__MODULE__{type: :three_point}) do
    %Statistics{
      statistics
      | blocked_shots: statistics.blocked_shots + 1,
        three_points_attempted: statistics.three_points_attempted + 1,
        field_goals_attempted: statistics.field_goals_attempted + 1
    }
  end
end
