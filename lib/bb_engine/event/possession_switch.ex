defmodule BBEngine.Event.PossessionSwitch do
  alias BBEngine.Player
  alias BBEngine.Possession
  alias BBEngine.GameState

  defstruct [
    :to_team,
    :to_player,
    :duration
  ]

  @type t :: %__MODULE__{
          to_team: Possession.t(),
          to_player: Player.id(),
          duration: non_neg_integer
        }

  @behaviour BBEngine.Event
  @impl true
  def update_game_state(game_state, event) do
    %GameState{
      game_state
      | ball_handler_id: event.to_player,
        possession: event.to_team,
        shot_clock: GameState.shot_clock_seconds()
    }
  end

  @impl true
  def update_statistics(statistics, _event) do
    # we don't record anything about passes atm
    statistics
  end
end
