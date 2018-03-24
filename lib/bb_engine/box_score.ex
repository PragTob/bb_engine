defmodule BBEngine.BoxScore do
  alias BBEngine.BoxScore.Statistics

  defstruct [
    :home,
    :road
  ]

  @behaviour Access

  defdelegate fetch(term, key), to: Map
  defdelegate get(term, key, default), to: Map
  defdelegate get_and_update(data, key, function), to: Map
  defdelegate pop(data, key), to: Map

  alias BBEngine.BoxScore.Statistics

  def new(home_squad, away_squad) do
    %__MODULE__{
      home: statistics(home_squad),
      road: statistics(away_squad)
    }
  end

  defp statistics(squad) do
    player_stats = Enum.map(squad.players, fn player -> {player.id, %Statistics{}} end)
    Map.new([{:team, %Statistics{}} | player_stats])
  end
end
