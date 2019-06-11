defmodule BBEngine.Event.FreeThrow do
  alias BBEngine.GameState
  alias BBEngine.Player
  alias BBEngine.Possession
  alias BBEngine.BoxScore
  alias BBEngine.BoxScore.Statistics

  defstruct [
    :actor_id,
    :team,
    :success,
    :duration,
    :free_throws_remaining
  ]

  @type t :: %__MODULE__{
          actor_id: Player.id(),
          team: Possession.t(),
          success: boolean,
          duration: non_neg_integer,
          free_throws_remaining: non_neg_integer
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

  defp shot_clock_seconds(_seconds, %__MODULE__{success: true}) do
    BoxScore.shot_clock_seconds()
  end

  defp shot_clock_seconds(seconds, _) do
    seconds
  end

  defp possession_after(possession, %__MODULE__{success: true}) do
    Possession.opposite(possession)
  end

  defp possession_after(possession, _missed_shot) do
    nil
  end

  defp update_statistics(statistics, shot = %__MODULE__{success: true}) do
    %Statistics{
      statistics
      | points: statistics.points + 1,
        free_throws_attempted: statistics.free_throws_attempted + 1,
        free_throws_made: statistics.free_throws_made + 1
    }
  end

  defp update_statistics(statistics, %__MODULE__{success: false}) do
    %Statistics{
      statistics
      | field_goals_attempted: statistics.field_goals_attempted + 1,
        free_throws_attempted: statistics.free_throws_attempted + 1
    }
  end
end
