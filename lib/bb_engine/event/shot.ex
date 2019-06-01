defmodule BBEngine.Event.Shot do
  alias BBEngine.GameState
  alias BBEngine.Player
  alias BBEngine.Possession
  alias BBEngine.BoxScore
  alias BBEngine.BoxScore.Statistics

  defstruct [
    :actor_id,
    :defender_id,
    :team,
    :type,
    :points,
    :success,
    :duration
  ]

  @type t :: %__MODULE__{
          actor_id: Player.id(),
          defender_id: Player.id(),
          team: Possession.t(),
          type: :midrange | :threepoint,
          points: 1..3,
          success: boolean,
          duration: non_neg_integer
        }

  @behaviour BBEngine.Event
  @impl true
  @spec update_game_state(GameState.t(), t) :: GameState.t()
  def update_game_state(game_state, event) do
    box_score =
      BoxScore.update(game_state.box_score, event.team, event.actor_id, fn stats ->
        update_statistics(stats, event)
      end)

    %GameState{
      game_state
      | ball_handler_id: nil,
        possession: possession_after(game_state.possession, event),
        box_score: %BoxScore{
          box_score
          | shot_clock: shot_clock_seconds(box_score.shot_clock, event)
        }
    }
  end

  defp possession_after(possession, %__MODULE__{success: true}) do
    Possession.opposite(possession)
  end

  defp possession_after(possession, _missed_shot) do
    possession
  end

  defp shot_clock_seconds(_seconds, %__MODULE__{success: true}) do
    BoxScore.shot_clock_seconds()
  end

  defp shot_clock_seconds(seconds, _) do
    seconds
  end

  defp update_statistics(statistics, shot = %__MODULE__{success: true, points: 2}) do
    %Statistics{
      statistics
      | points: statistics.points + shot.points,
        field_goals_attempted: statistics.field_goals_attempted + 1,
        field_goals_made: statistics.field_goals_made + 1,
        two_points_attempted: statistics.two_points_attempted + 1,
        two_points_made: statistics.two_points_made + 1
    }
  end

  defp update_statistics(statistics, shot = %__MODULE__{success: true, points: 3}) do
    %Statistics{
      statistics
      | points: statistics.points + shot.points,
        field_goals_attempted: statistics.field_goals_attempted + 1,
        field_goals_made: statistics.field_goals_made + 1,
        three_points_attempted: statistics.three_points_attempted + 1,
        three_points_made: statistics.three_points_made + 1
    }
  end

  defp update_statistics(statistics, %__MODULE__{success: false, points: 2}) do
    %Statistics{
      statistics
      | field_goals_attempted: statistics.field_goals_attempted + 1,
        two_points_attempted: statistics.two_points_attempted + 1
    }
  end

  defp update_statistics(statistics, %__MODULE__{success: false, points: 3}) do
    %Statistics{
      statistics
      | field_goals_attempted: statistics.field_goals_attempted + 1,
        three_points_attempted: statistics.three_points_attempted + 1
    }
  end
end
