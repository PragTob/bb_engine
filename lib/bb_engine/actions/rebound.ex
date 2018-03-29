defmodule BBEngine.Event.Rebound do
  alias BBEngine.Player
  alias BBEngine.Possession

  defstruct [
    :actor_id,
    :duration,
    :team,
    :type
  ]

  @type t :: %__MODULE__{
    actor_id: Player.id,
    duration: non_neg_integer,
    team: Possession.t,
    type: :offensive | :defensive
  }
end

defmodule BBEngine.Actions.Rebound do
  alias BBEngine.Random
  alias BBEngine.GameState
  alias BBEngine.Event
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

    event = %Event.Rebound{
      actor_id: rebounder.id,
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
  defp rebound_type(team, team), do: :offensive
  defp rebound_type(_, _), do: :defensive

  defp update_game_state({game_state, event}) do
    {
      %GameState{game_state |
        ball_handler_id: event.actor_id,
        possession: event.team,
        shot_clock: shot_clock_seconds(event)
      },
      event
    }
  end

  defp shot_clock_seconds(%Event.Rebound{type: :offensive}), do: 14
  defp shot_clock_seconds(_), do: GameState.shot_clock_seconds()
end
