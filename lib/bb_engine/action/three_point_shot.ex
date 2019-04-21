defmodule BBEngine.Action.ThreePointShot do
  alias BBEngine.Random
  alias BBEngine.Event
  alias BBEngine.GameState
  alias BBEngine.Player

  @behaviour BBEngine.Action

  @impl true
  @spec play(GameState.t()) :: {GameState.t(), Event.Shot.t()}
  def play(game_state) do
    {ball_handler, defender} = GameState.on_ball_matchup(game_state)

    {game_state, elapsed_time} = elapsed_time(game_state)
    {game_state, shot_event} = attempt(game_state, ball_handler, defender, elapsed_time)

    {game_state, shot_event}
  end

  @three_point_difficulty_modifier 0.5
  @makes_shot {:shot, true}
  @misses_shot {:shot, false}

  @spec attempt(GameState.t(), Player.t(), Player.t(), non_neg_integer, number) ::
          {GameState.t(), Event.Shot.t() | Event.Block.t()}
  def attempt(game_state, ball_handler, opponent, duration, offensive_adjustment \\ 0) do
    probabilities = %{
      @makes_shot =>
        (ball_handler.offensive_rating + offensive_adjustment) * @three_point_difficulty_modifier,
      @misses_shot => 0.99 * opponent.defensive_rating,
      :blocked => 0.01 * opponent.defensive_rating
    }

    {game_state, result} = Random.weighted(game_state, probabilities)

    {game_state, resulting_event(result, ball_handler, opponent, duration)}
  end

  defp resulting_event({:shot, success}, ball_handler, defender, duration) do
    %Event.Shot{
      actor_id: ball_handler.id,
      defender_id: defender.id,
      team: ball_handler.team,
      success: success,
      type: :threepoint,
      points: 3,
      duration: duration
    }
  end

  defp resulting_event(:blocked, ball_handler, defender, duration) do
    %Event.Block{
      actor_id: defender.id,
      blocked_player_id: ball_handler.id,
      type: :three_point,
      team: defender.team,
      duration: duration
    }
  end

  @max_duration 6
  defp elapsed_time(game_state) do
    Random.uniform_int(game_state, @max_duration)
  end
end
