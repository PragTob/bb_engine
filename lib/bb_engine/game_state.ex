defmodule BBEngine.GameState do
  alias BBEngine.{BoxScore, Squad, Player, Random}

  defstruct [
    :quarter,
    :clock_seconds,
    :ball_handler_id,
    :possession,
    :box_score,
    :home,
    :road,
    :players,
    :matchups,
    :initial_seed,
    :current_seed,
    events: []
  ]

  @minutes_per_quarter 10
  @seconds_per_quarter 60 * @minutes_per_quarter

  def new(home_squad, road_squad, initial_seed) do
    {home_squad, road_squad} = set_court(home_squad, road_squad)
    seed = Random.seed(initial_seed)

    %__MODULE__{
      quarter: 1,
      clock_seconds: @seconds_per_quarter,
      box_score: BoxScore.new(home_squad, road_squad),
      home: home_squad,
      road: road_squad,
      players: players_map(home_squad, road_squad),
      matchups: assign_matchups(home_squad, road_squad),
      initial_seed: seed, # export with :rand.export_seed
      current_seed: seed
    }
  end

  def seconds_per_quarter, do: @seconds_per_quarter

  defp set_court(home_squad = %{players: home}, road_squad = %{players: road}) do
    home_squad = %Squad{home_squad | players: your_court(home, :home)}
    road_squad = %Squad{road_squad | players: your_court(road, :road)}

    {home_squad, road_squad}
  end

  defp your_court(players, court) do
    Enum.map players, fn(player) -> %Player{player | court: court} end
  end

  defp players_map(one_squad, another_squad) do
    (one_squad.players ++ another_squad.players)
    |> Enum.map(fn(player) -> {player.id, player} end)
    |> Map.new
  end

  defp assign_matchups(one_squad, another_squad) do
    (one_squad.lineup ++ another_squad.lineup)
    |> Enum.zip(another_squad.lineup ++ one_squad.lineup)
    |> Map.new
  end
end
