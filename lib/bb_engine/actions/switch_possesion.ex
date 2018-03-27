defmodule BBEngine.Event.PossessionSwitch do

  alias BBEngine.Player
  alias BBEngine.Possession

  defstruct [
    :to_team,
    :to_player,
    :duration
  ]

  @type t :: %__MODULE__{
    to_team: Possession.t,
    to_player: Player.id,
    duration: non_neg_integer
  }
end

defmodule BBEngine.Actions.SwitchPossession do
  alias BBEngine.GameState
  alias BBEngine.Event.PossessionSwitch
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
