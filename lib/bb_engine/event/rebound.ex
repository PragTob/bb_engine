defmodule BBEngine.Event.Rebound do
  alias BBEngine.Player
  alias BBEngine.Possession
  alias BBEngine.GameState
  alias BBEngine.Event

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
  def apply(game_state, event) do
    %GameState{
      game_state
      | ball_handler_id: event.actor_id,
        possession: event.team,
        shot_clock: shot_clock_seconds(event)
    }
  end

  defp shot_clock_seconds(%Event.Rebound{type: :offensive}), do: 14
  defp shot_clock_seconds(_), do: GameState.shot_clock_seconds()
end
