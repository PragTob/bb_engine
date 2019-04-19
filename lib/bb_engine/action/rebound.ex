defmodule BBEngine.Action.Rebound do
  alias BBEngine.Random
  alias BBEngine.GameState
  alias BBEngine.Event
  alias BBEngine.Player
  alias BBEngine.Possession

  @behaviour BBEngine.Action

  @impl true
  @spec play(GameState.t()) :: {GameState.t(), Event.Rebound.t()}
  def play(game_state) do
    game_state
    |> simulate_action()
  end

  @rebound_duration 2
  defp simulate_action(game_state) do
    offense = game_state.possession

    offensive_rebound = skills(game_state, offense, :offensive_rebound)
    defensive_rebound = skills(game_state, Possession.opposite(offense), :defensive_rebound)

    rebounding_map = Map.merge(offensive_rebound, defensive_rebound)

    {new_game_state, rebounder} = Random.weighted(game_state, rebounding_map)

    event = %Event.Rebound{
      actor_id: rebounder.id,
      duration: @rebound_duration,
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
end
