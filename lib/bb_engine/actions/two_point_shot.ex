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
          actor_id: Player.id(),
          defender_id: Player.id(),
          team: Possession.t(),
          # unused atm
          type: nil,
          success: boolean,
          duration: non_neg_integer
        }
end

defmodule BBEngine.Action.TwoPointShot do
  alias BBEngine.Random
  alias BBEngine.Event
  alias BBEngine.GameState
  alias BBEngine.Player

  def play(game_state) do
    {ball_handler, defender} = GameState.on_ball_matchup(game_state)

    {game_state, shot_event} = attempt(game_state, ball_handler, defender)
    {game_state, elapsed_time} = elapsed_time(game_state)

    {game_state, %Event.Shot{shot_event | duration: elapsed_time}}
  end

  @spec attempt(GameState.t(), Player.t(), Player.t(), number) :: {GameState.t(), Event.Shot.t()}
  def attempt(game_state, ball_handler, opponent, offensive_malus \\ 0) do
    {game_state, success} =
      Random.successful?(
        game_state,
        ball_handler.offensive_rating - offensive_malus,
        opponent.defensive_rating
      )

    event = %Event.Shot{
      actor_id: ball_handler.id,
      defender_id: opponent.id,
      team: ball_handler.team,
      success: success,
      # honestly hack so don't have to define another type
      duration: 0
    }

    {game_state, event}
  end

  @max_duration 6
  defp elapsed_time(game_state) do
    Random.uniform(game_state, @max_duration)
  end
end
