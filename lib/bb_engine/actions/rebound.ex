defmodule BBEngine.Events.Rebound do
  defstruct [
    :rebounder,
    :duration,
    :team
  ]
end

defmodule BBEngine.Actions.Rebound do
  alias BBEngine.Random
  alias BBEngine.GameState
  alias BBEngine.BoxScore
  alias BBEngine.Events
  alias BBEngine.Player

  def play(game_state) do
    game_state
    |> simulate_action()
    |> update_game_state()
  end

  defp simulate_action(game_state) do
    offense = game_state.possession
    defense = opposite(offense)

    defensive_players = GameState.players(game_state, offense)
    offensive_players = GameState.players(game_state, defense)

    offensive_rebound = Player.skill_map(offensive_players, :offensive_rebound)
    defensive_rebound = Player.skill_map(defensive_players, :defensive_rebound)

    rebounding_map =
      Map.merge(offensive_rebound, defensive_rebound, fn _, _, _ -> raise "boom" end)

    {new_game_state, rebounder} = Random.weighted(game_state, rebounding_map)

    event = %Events.Rebound{rebounder: rebounder.id, duration: 2, team: rebounder.team}

    {new_game_state, event}
  end

  defp update_game_state({game_state, event}) do
    # update box score damn it
    {
      %GameState{game_state | ball_handler_id: event.rebounder, possession: event.team},
      event
    }
  end

  # Temporary copy
  defp opposite(:home), do: :road
  defp opposite(:road), do: :home
end
