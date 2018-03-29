defmodule BBEngine.Event.Shot do
  alias BBEngine.Player
  alias BBEngine.Possession

  defstruct [
    :actor_id,
    :defender_id,
    :team,
    :type,
    :success,
    :duration
  ]

  @type t :: %__MODULE__{
    actor_id: Player.id,
    defender_id: Player.id,
    team: Possession.t,
    type: nil, #unused atm
    success: boolean,
    duration: non_neg_integer
  }

end

defmodule BBEngine.Action.TwoPointShot do
  alias BBEngine.Random
  alias BBEngine.Event.Shot
  alias BBEngine.GameState

  def play(game_state = %GameState{ball_handler_id: ball_handler_id}) do
    opponent_id = Map.fetch!(game_state.matchups, ball_handler_id)
    opponent = Map.fetch! game_state.players, opponent_id
    ball_handler = Map.fetch! game_state.players, ball_handler_id
    {new_game_state, elapsed_time} = elapsed_time(game_state)
    shot = %Shot{
      actor_id: ball_handler_id,
      defender_id: opponent_id,
      team: ball_handler.team,
      duration: elapsed_time
    }
    {final_game_state, success} =
      Random.successful?(new_game_state, ball_handler.offensive_rating, opponent.defensive_rating)
    {final_game_state, %Shot{shot | success: success}}
  end

  defp elapsed_time(game_state) do
    Random.uniform(game_state, 6)
  end
end
