defmodule BBEngine.Events.Rebound do
  defstruct [
    :rebounder_id,
    :duration,
    :team,
    :type
  ]
end

defmodule BBEngine.Actions.Rebound do
  alias BBEngine.Random
  alias BBEngine.GameState
  alias BBEngine.BoxScore
  alias BBEngine.Events
  alias BBEngine.Player
  alias BBEngine.Possession

  def play(game_state) do
    game_state
    |> simulate_action()
    |> update_game_state()
  end

  defp simulate_action(game_state) do
    offense = game_state.possession

    offensive_rebound = skills(game_state, offense, :offensive_rebound)
    defensive_rebound = skills(game_state, Possession.opposite(offense), :defensive_rebound)

    rebounding_map =
      Map.merge(offensive_rebound, defensive_rebound)

    {new_game_state, rebounder} = Random.weighted(game_state, rebounding_map)

    event = %Events.Rebound{
      rebounder_id: rebounder.id,
      duration: 2,
      team: rebounder.team,
      type: rebound_type(rebounder.team, offense)
    }

    {new_game_state, event}
  end

  defp skills(game_state, team, skill) do
    game_state
    |> GameState.players(team)
    |> Player.skill_map(skill)
  end

  defp rebound_type(rebounder_team, offense_team)
  defp rebound_type(team, team), do: "offensive"
  defp rebound_type(_, _), do: "defensive"

  defp update_game_state({game_state, event}) do
    # update box score damn it
    {
      %GameState{game_state |
        ball_handler_id: event.rebounder_id,
        possession: event.team,
        box_score: update_box_score(game_state.box_score, event)
      },
      event
    }
  end

  defp update_box_score(box_score, event) do
    squad_box_score = Map.fetch! box_score, event.team
    individual_box_score = apply_event(squad_box_score[event.rebounder_id], event)
    team_box_score = apply_event(squad_box_score[:team], event)
    updated_squad_box_score = %{
      squad_box_score |
      event.rebounder_id => individual_box_score,
      team: team_box_score
    }
    %{box_score | event.team => updated_squad_box_score}
  end

  defp apply_event(statistics, %Events.Rebound{type: "defensive"}) do
    %BoxScore.Statistics{
      statistics |
      defensive_rebounds: statistics.defensive_rebounds + 1,
      rebounds: statistics.rebounds + 1
    }
  end

  defp apply_event(statistics, %Events.Rebound{type: "offensive"}) do
    %BoxScore.Statistics{
      statistics |
      offensive_rebounds: statistics.offensive_rebounds + 1,
      rebounds: statistics.rebounds + 1
    }
  end
end
