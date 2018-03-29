defmodule BBEngine.GameState do
  alias BBEngine.{BoxScore, Squad, Player, Random, Possession}

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

  @type t :: %__MODULE__{
    quarter: pos_integer,
    clock_seconds: integer,
    ball_handler_id: Player.id,
    possession: Possession.t,
    box_score: BoxScore.t,
    home: Squad.t,
    road: Squad.t,
    players: %{Player.id => Player.t},
    matchups: map, #unused
    initial_seed: Random.state,
    current_seed: Random.state,
    events: [BBEngine.Event.t]
  }

  @type initial :: %__MODULE__{
    quarter: 1,
    clock_seconds: 600,
    ball_handler_id: nil,
    possession: nil,
    box_score: BoxScore.t,
    home: Squad.t,
    road: Squad.t,
    players: %{Player.id => Player.t},
    matchups: map, #unused
    initial_seed: Random.state,
    current_seed: Random.state,
    events: []
  }

  @minutes_per_quarter 10
  @seconds_per_quarter 60 * @minutes_per_quarter

  @spec new(Squad.t, Squad.t, Random.state) :: __MODULE__.initial
  def new(home_squad, road_squad, initial_seed \\ Random.seed()) do
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

  @spec players(t, Possession.t) :: [Player.t, ...]
  def players(game_state, team) do
    game_state
    |> lineup(team)
    |> Enum.map(fn id -> Map.fetch!(game_state.players, id) end)
  end

  def offense_lineup(game_state) do
    # rename possession to offense?
    lineup(game_state, game_state.possession)
  end

  @spec lineup(t, Possession.t) :: [Player.id, ...]
  def lineup(game_state, team) do
    game_state
    |> Map.fetch!(team)
    |> Map.fetch!(:lineup)
  end

  defp set_court(home_squad = %{players: home}, road_squad = %{players: road}) do
    home_squad = %Squad{home_squad | players: your_court(home, :home)}
    road_squad = %Squad{road_squad | players: your_court(road, :road)}

    {home_squad, road_squad}
  end

  defp your_court(players, court) do
    Enum.map players, fn(player) -> %Player{player | team: court} end
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
