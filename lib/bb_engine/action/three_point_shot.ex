defmodule BBEngine.Action.ThreePointShot do
  alias BBEngine.Random
  alias BBEngine.Event
  alias BBEngine.GameState
  alias BBEngine.Player
  alias BBEngine.Action.TwoPointShot

  @behaviour BBEngine.Action

  @type result :: TwoPointShot.result()

  @impl true
  @spec play(GameState.t()) :: {GameState.t(), result}
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
          {GameState.t(), result}
  def attempt(game_state, ball_handler, defender, duration, offensive_adjustment \\ 0) do
    probabilities = %{
      @makes_shot =>
        (ball_handler.offensive_rating + offensive_adjustment) * @three_point_difficulty_modifier,
      @misses_shot => 0.99 * defender.defensive_rating,
      :blocked => 0.01 * defender.defensive_rating,
      :foul_before_shot => 0.02 * ball_handler.offensive_rating - 0.01 * defender.defensive_rating
    }

    {game_state, result} = Random.weighted(game_state, probabilities)

    {game_state, resulting_event(result, ball_handler, defender, duration)}
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

  defp resulting_event(:foul_before_shot, ball_handler, defender, duration) do
    %Event.Foul{
      actor_id: defender.id,
      team: defender.team,
      fouled_player_id: ball_handler.id,
      during_shot: false,
      duration: duration
    }
  end

  @max_duration 6
  defp elapsed_time(game_state) do
    Random.uniform_int(game_state, @max_duration)
  end
end
