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
  alias BBEngine.Player
  alias BBEngine.Events

  def play(game_state) do
    game_state
    |> simulate_action()
    |> update_game_state()
  end

  defp simulate_action(game_state) do
    offense = game_state.possession
    defense = opposite(offense)

    defensive_players = players(game_state, offense)
    offensive_players = players(game_state, defense)

    offensive_rebound = skill_score(offensive_players, :offensive_rebound)
    defensive_rebound = skill_score(defensive_players, :defensive_rebound)

    {new_game_state, success} =
      Random.successful?(game_state, defensive_rebound, offensive_rebound)

    {{new_game_state, rebounder}, team} =
      if success do
        {Random.list_element(new_game_state, defensive_players), defense}
      else
        {Random.list_element(new_game_state, offensive_players), offense}
      end

    event = 
      %Events.Rebound{
        rebounder: rebounder.id,
        duration: 2,
        team: team
      }
    
    {new_game_state, event}
  end

  defp skill_score(players, skill) do
    players
    |> Enum.map(fn %{^skill => value} -> value end)
    |> Enum.sum
  end

  defp players(game_state, court) do
    game_state
    |> Map.fetch!(court)
    |> Map.fetch!(:lineup)
    |> Enum.map(fn id -> Map.fetch!(game_state.players, id) end)
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