defmodule BBEngine.Event.EndOfQuarter do
  alias BBEngine.GameState

  @doc """
  Time of the quarter ran out. Play subsides, no TOs or whatever are handed out.
  """

  defstruct [:duration]

  @type t :: %__MODULE__{
          duration: non_neg_integer
        }

  @behaviour BBEngine.Event
  @impl true
  @spec update_game_state(GameState.t(), t) :: GameState.t()
  def update_game_state(game_state, _event) do
    new_quarter = game_state.quarter + 1

    %GameState{
      game_state
      | ball_handler_id: nil,
        quarter: new_quarter,
        clock_seconds: quarter_seconds(new_quarter),
        shot_clock: GameState.shot_clock_seconds()
    }
  end

  @final_quarter GameState.final_quarter()
  @seconds_per_quarter GameState.seconds_per_quarter()
  @seconds_per_overtime 5 * 60
  defp quarter_seconds(quarter) when quarter <= @final_quarter, do: @seconds_per_quarter
  defp quarter_seconds(_quarter), do: @seconds_per_overtime
end
