defmodule BBEngine.Substitution do
  alias BBEngine.{GameState, Player, Possession, Squad}

  defstruct [
    :to_substitute_id,
    :substitute_id
    # reason?
  ]

  @type t :: %__MODULE__{
          to_substitute_id: Player.id(),
          substitute_id: Player.id()
        }

  # force_substitute happens when a player fouls out
  # or injures themselves
  @spec force_substitute(GameState.t(), Possession.t(), Player.id()) :: GameState.t()
  def force_substitute(game_state, team, player_id) do
    # probably take into account something like set positions
    # or special tactics/settings whom to replace with whom
    squad = Map.fetch!(game_state, team)
    [replacement_id | _] = squad.bench

    perform_substitution(game_state, team, player_id, replacement_id)
  end

  defp perform_substitution(game_state, team, player_id, replacement_id) do
    squad = Map.fetch!(game_state, team)

    squad = %Squad{
      squad
      | lineup: update_lineup(squad.lineup, player_id, replacement_id),
        ineligible: [player_id | squad.ineligible]
    }

    # update play time statistics

    game_state = Map.put(game_state, team, squad)

    substitution = %__MODULE__{
      to_substitute_id: player_id,
      substitute_id: replacement_id
    }

    %GameState{
      game_state
      | events: [substitution | game_state.events],
        matchups: update_matchups(game_state.matchups, player_id, replacement_id)
    }
  end

  @spec update_lineup(Squad.lineup(), Player.id(), Player.id()) :: Squad.lineup()
  defp update_lineup(lineup, current_id, replacement_id) do
    Enum.map(lineup, fn player_id ->
      if player_id == current_id do
        replacement_id
      else
        player_id
      end
    end)
  end

  defp update_matchups(matchups, current_id, replacement_id) do
    matchups
    |> Enum.map(fn {defender_id, offense_id} ->
      cond do
        defender_id == current_id -> {replacement_id, offense_id}
        offense_id == current_id -> {defender_id, replacement_id}
        true -> {defender_id, offense_id}
      end
    end)
    |> Map.new()
  end
end
