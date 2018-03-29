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
  alias BBEngine.Event
  alias BBEngine.GameState

  def play(game_state = %GameState{ball_handler_id: ball_handler_id}) do
    {game_state, shot_event} = attempt(game_state)
    {game_state, elapsed_time} = elapsed_time(game_state)

    {game_state, %Event.Shot{shot_event | duration: elapsed_time}}
  end

  @spec attempt(GameState.t, number) :: {GameState.t, Event.Shot.t}
  def attempt(game_state = %GameState{ball_handler_id: ball_handler_id}, offensive_malus \\ 0) do
    opponent_id = Map.fetch!(game_state.matchups, ball_handler_id)
    opponent = Map.fetch! game_state.players, opponent_id
    ball_handler = Map.fetch! game_state.players, ball_handler_id
    {game_state, success} =
      Random.successful?(game_state, ball_handler.offensive_rating, opponent.defensive_rating)

    event = %Event.Shot{
      actor_id: ball_handler_id,
      defender_id: opponent_id,
      team: ball_handler.team,
      success: success,
      duration: 0 # honestly hack so don't have to define another type
    }

    {game_state, event}
  end

  defp elapsed_time(game_state) do
    Random.uniform(game_state, 6)
  end
end
