defmodule BBEngine.Action.SwitchPossession do
  alias BBEngine.GameState
  alias BBEngine.Event
  alias BBEngine.Random
  import BBEngine.Possession

  @behaviour BBEngine.Action

  @impl true
  @spec play(GameState.t()) :: {GameState.t(), Event.PossessionSwitch.t()}
  def play(game_state = %GameState{possession: possession}) do
    opponent = opposite(possession)
    opponent_lineup = Map.fetch!(game_state, opponent).lineup
    {new_game_state, new_ball_handler} = Random.list_element(game_state, opponent_lineup)

    event = %Event.PossessionSwitch{
      to_team: opponent,
      to_player: new_ball_handler,
      duration: 0
    }

    {
      %GameState{
        new_game_state
        | ball_handler_id: new_ball_handler,
          possession: opponent,
          shot_clock: GameState.shot_clock_seconds()
      },
      event
    }
  end
end
