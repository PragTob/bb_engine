defmodule BBEngine.Action.Pass do
  alias BBEngine.GameState
  alias BBEngine.Random
  alias BBEngine.Event
  alias BBEngine.Possession

  @behaviour BBEngine.Action

  @impl true
  @spec play(GameState.t()) ::
          {GameState.t(), Event.Pass.t() | Event.Steal.t() | Event.Turnover.t()}
  def play(game_state) do
    game_state
    |> what_happens()
    |> simulate_action()
  end

  @minimum_turnover_score 0.5
  @minimum_steal_score 0.1
  @force_turnover_skill_modifier 0.1
  defp what_happens(game_state) do
    {ball_handler, defender} = GameState.on_ball_matchup(game_state)

    # obviously these should take into account dribbling, experience, passing etc...
    # it also very obviously needs some work...
    force_turn_over_score = @force_turnover_skill_modifier * defender.defensive_rating

    probabilities = %{
      pass: ball_handler.offensive_rating,
      turnover: max(0.4 * force_turn_over_score, @minimum_turnover_score),
      steal: max(0.2 * force_turn_over_score, @minimum_steal_score)
    }

    Random.weighted(game_state, probabilities)
  end

  defp simulate_action({game_state, :pass}) do
    {game_state, receiver_id} = choose_receiver(game_state)
    {game_state, duration} = duration(game_state)

    event = %Event.Pass{
      actor_id: game_state.ball_handler_id,
      receiver_id: receiver_id,
      duration: duration,
      team: game_state.possession
    }

    {game_state, event}
  end

  defp simulate_action({game_state, :turnover}) do
    {game_state, duration} = duration(game_state)

    event = %Event.Turnover{
      actor_id: game_state.ball_handler_id,
      duration: duration,
      team: game_state.possession,
      type: :out_of_bound_pass
    }

    {game_state, event}
  end

  defp simulate_action({game_state, :steal}) do
    ball_handler_id = game_state.ball_handler_id
    {game_state, duration} = duration(game_state)

    event = %Event.Steal{
      actor_id: GameState.matchup_player_id(game_state, ball_handler_id),
      stolen_from: ball_handler_id,
      duration: duration,
      team: Possession.opposite(game_state.possession)
    }

    {game_state, event}
  end

  @pass_max_duration 5
  defp duration(game_state) do
    Random.uniform_int(game_state, @pass_max_duration)
  end

  defp choose_receiver(game_state) do
    # take into account offensive focus as well as offensive skills and defensive pressure
    Random.list_element(game_state, GameState.offense_lineup(game_state))
  end
end
