defmodule BBEngine.Action.Forced do
  alias BBEngine.GameState
  alias BBEngine.Random
  alias BBEngine.Event
  alias BBEngine.Action.TwoPointShot

  @behaviour BBEngine.Action

  @impl true
  @spec play(GameState.t()) :: {GameState.t(), Event.Shot.t() | Event.Turnover.t()}
  def play(game_state) do
    {ball_handler, defender} = GameState.on_ball_matchup(game_state)
    remaining_time = GameState.remaining_time(game_state)

    {game_state, time_ran_out?} =
      time_ran_out?(game_state, ball_handler, defender, remaining_time)

    if time_ran_out? || remaining_time == 0 do
      time_violation(game_state)
    else
      {game_state, duration} = elapsed_time(game_state, remaining_time)
      shot_attempt(game_state, ball_handler, defender, duration)
    end
  end

  defp time_ran_out?(game_state, ball_handler, opponent, _remaining_time) do
    # take into account time and maybe experience etc...
    Random.successful?(game_state, ball_handler.offensive_rating, opponent.defensive_rating)
  end

  defp time_violation(game_state) do
    event =
      if end_of_quarter?(game_state) do
        %Event.EndOfQuarter{
          duration: game_state.clock_seconds
        }
      else
        %Event.Turnover{
          actor_id: game_state.ball_handler_id,
          team: game_state.possession,
          type: :clock_violation,
          duration: game_state.shot_clock
        }
      end

    {game_state, event}
  end

  defp end_of_quarter?(game_state) do
    game_state.clock_seconds <= game_state.shot_clock
  end

  @forced_shot_malus -15
  defp shot_attempt(game_state, ball_handler, defender, duration) do
    # TODO: make the malus dependent on the player... like a percent of their
    # skills but also dependent on experience - might even become a boon for
    # very special players sometimes
    # We could also pass here.. dunnoo... also on the time.
    {game_state, shot_event} =
      TwoPointShot.attempt(
        game_state,
        ball_handler,
        defender,
        duration,
        @forced_shot_malus
      )

    {game_state, shot_event}
  end

  defp elapsed_time(game_state, remaining_time) do
    if remaining_time > 0 do
      Random.uniform_int(game_state, remaining_time)
    else
      {game_state, 0}
    end
  end
end
