defmodule BBEngine.Event.ClockViolation do
  alias BBEngine.Player
  alias BBEngine.Possession

  defstruct [
    :actor_id,
    :team,
    duration: 0
  ]

  @type t :: %__MODULE__{
    actor_id: Player.id,
    team: Possession.t,
    duration: non_neg_integer
  }
end

defmodule BBEngine.Action.Forced do
  alias BBEngine.GameState
  alias BBEngine.Random
  alias BBEngine.Event
  alias BBEngine.Action.TwoPointShot

  def play(game_state) do
    {ball_handler, defender} = GameState.on_ball_matchup(game_state)

    {game_state, turnover?} = turnover?(game_state, ball_handler, defender)

    if turnover? do
      turnover(game_state, ball_handler)
    else
      shot_attempt(game_state, ball_handler, defender)
    end
  end

  defp turnover?(game_state, ball_handler, opponent) do
    # take into account time and maybe experience etc...
    Random.successful?(game_state, ball_handler.offensive_rating, opponent.defensive_rating)
  end

  defp shot_attempt(game_state, ball_handler, defender) do
    # TODO: make the malus dependent on the player... like a percent of their
    # skills but also dependent on experience - might even become a boon for
    # very special players sometimes
    # We could also pass here.. dunnoo... also on the time.
    {game_state, shot_event} = TwoPointShot.attempt(game_state, ball_handler, defender, 15)
    {game_state, elapsed_time} = elapsed_time(game_state)

    {game_state, %Event.Shot{shot_event | duration: elapsed_time}}
  end

  defp turnover(game_state, ball_handler) do
    {
      game_state,
      %Event.ClockViolation{actor_id: ball_handler.id, team: ball_handler.team}
    }
  end
  

  defp elapsed_time(game_state = %GameState{shot_clock: shot_clock}) do
    Random.uniform(game_state, shot_clock)
  end
end