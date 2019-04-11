defmodule BBEngine.Action.TwoPointShot do
  alias BBEngine.Random
  alias BBEngine.Event
  alias BBEngine.GameState
  alias BBEngine.Player

  @behaviour BBEngine.Action

  @impl true
  @spec play(GameState.t()) :: {GameState.t(), Event.Shot.t()}
  def play(game_state) do
    {ball_handler, defender} = GameState.on_ball_matchup(game_state)

    {game_state, shot_event} = attempt(game_state, ball_handler, defender)
    {game_state, elapsed_time} = elapsed_time(game_state)

    event = %Event.Shot{shot_event | duration: elapsed_time}

    {game_state, event}
  end

  @spec attempt(GameState.t(), Player.t(), Player.t(), number) :: {GameState.t(), Event.Shot.t()}
  def attempt(game_state, ball_handler, opponent, offensive_adjustment \\ 0) do
    {game_state, success} =
      Random.successful?(
        game_state,
        ball_handler.offensive_rating + offensive_adjustment,
        opponent.defensive_rating
      )

    event = %Event.Shot{
      actor_id: ball_handler.id,
      defender_id: opponent.id,
      team: ball_handler.team,
      success: success,
      type: :midrange,
      points: 2,
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
