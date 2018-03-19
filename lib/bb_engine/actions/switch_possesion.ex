defmodule BBEngine.Events.PossessionSwitch do
  defstruct [
    :to_team,
    :to_player,
    :duration
  ]
end

defmodule BBEngine.Actions.SwitchPossession do
  alias BBEngine.GameState
  alias BBEngine.Events.PossessionSwitch
  alias BBEngine.Random
  import BBEngine.Possession

  def play(game_state = %GameState{possession: possession}) do
    opponent = opposite(possession)
    opponent_lineup = Map.fetch!(game_state, opponent).lineup
    {new_game_state, new_ball_handler} = Random.list_element(game_state, opponent_lineup)

    event = %PossessionSwitch{
      to_team: opponent,
      to_player: new_ball_handler,
      duration: 0
    }

    {
      %GameState{new_game_state | ball_handler_id: new_ball_handler, possession: opponent},
      event
    }
  end
end
