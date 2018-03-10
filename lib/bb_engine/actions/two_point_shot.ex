defmodule BBEngine.Events.Shot do
  defstruct [
    :shooter,
    :defender,
    :type,
    :success,
    :duration
  ]
end

defmodule BBEngine.Actions.TwoPointShot do
  alias BBEngine.Random
  alias BBEngine.Events.Shot
  alias BBEngine.GameState
  alias BBEngine.BoxScore

  def play(game_state) do
    game_state
    |> simulate_action()
    |> update_game_state()
  end

  defp simulate_action(game_state = %GameState{ball_handler_id: ball_handler_id}) do
    opponent_id = Map.fetch!(game_state.matchups, ball_handler_id)
    opponent = Map.fetch! game_state.players, opponent_id
    ball_handler = Map.fetch! game_state.players, ball_handler_id
    {new_game_state, elapsed_time} = elapsed_time(game_state)
    shot = %Shot{
      shooter: ball_handler,
      defender: opponent,
      duration: elapsed_time
    }
    {final_game_state, success} =
      Random.successful?(new_game_state, ball_handler.offensive_rating, opponent.defensive_rating)
    {final_game_state, %Shot{shot | success: success}}
  end

  defp elapsed_time(game_state) do
    {new_game_state, random} = Random.uniform(game_state, 14)
    elapsed_time = 10 + random
    {new_game_state, elapsed_time}
  end

  defp update_game_state({game_state, shot_result}) do
    {update_box_score(game_state, shot_result), shot_result}
  end

  defp update_box_score(game_state = %GameState{box_score: box_score}, event) do
    updated_box_score = box_score
                        |> update_box_score_shooter(event)
                        |> update_box_score_total(event)
    %GameState{game_state | box_score: updated_box_score}
  end

  defp update_box_score_shooter(box_score, event = %{shooter: offense}) do
    individual =
      Map.update! box_score.individual, offense.id, fn(statisticss) ->
        apply_event(statisticss, event)
      end

    %BoxScore{box_score | individual: individual}
  end

  defp update_box_score_total(box_score, event = %{shooter: offense}) do
    team =
      Map.update! box_score.team, offense.court, fn(statistics) ->
        apply_event(statistics, event)
      end

    %BoxScore{box_score | team: team}
  end

  defp apply_event(statistics, %Shot{success: true}) do
    %BoxScore.Statistics{
      statistics |
      points: statistics.points + 2,
      field_goals_attempted: statistics.field_goals_attempted + 1,
      field_goals_made: statistics.field_goals_made + 1,
    }
  end
  defp apply_event(statistics, %Shot{success: false}) do
    %BoxScore.Statistics{
      statistics |
      field_goals_attempted: statistics.field_goals_attempted + 1
    }
  end
end
