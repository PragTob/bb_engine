defmodule BBEngine.GameState do
  alias BBEngine.{BoxScore, Squad, Player, Random, Possession}

  @shot_clock_seconds 24

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
    shot_clock: @shot_clock_seconds,
    events: []
  ]

  @type t :: %__MODULE__{
          quarter: pos_integer,
          clock_seconds: integer,
          ball_handler_id: Player.id() | nil,
          possession: Possession.t() | nil,
          box_score: BoxScore.t(),
          home: Squad.t(),
          road: Squad.t(),
          players: %{Player.id() => Player.t()},
          matchups: %{Player.id() => Player.id()},
          initial_seed: Random.state(),
          current_seed: Random.state(),
          shot_clock: non_neg_integer,
          events: [BBEngine.Event.t()] | []
        }

  @minutes_per_quarter 10
  @seconds_per_quarter 60 * @minutes_per_quarter

  @spec new(Squad.t(), Squad.t(), Random.state()) :: t
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
      # export with :rand.export_seed
      initial_seed: seed,
      current_seed: seed
    }
  end

  @spec seconds_per_quarter() :: 600
  def seconds_per_quarter, do: @seconds_per_quarter

  @spec current_players(t, Possession.t()) :: [Player.t(), ...]
  def current_players(game_state, team) do
    game_state
    |> lineup(team)
    |> Enum.map(fn id -> Map.fetch!(game_state.players, id) end)
  end

  @spec offense_lineup(t) :: [Player.id()]
  def offense_lineup(game_state) do
    # rename possession to offense?
    lineup(game_state, game_state.possession)
  end

  @spec lineup(t, Possession.t()) :: [Player.id(), ...]
  def lineup(game_state, team) do
    game_state
    |> Map.fetch!(team)
    |> Map.fetch!(:lineup)
  end

  @spec on_ball_matchup(t) :: {Player.t(), Player.t()}
  def on_ball_matchup(game_state) do
    ball_handler = player(game_state, game_state.ball_handler_id)
    defender = matchup_player(game_state, ball_handler.id)

    {ball_handler, defender}
  end

  @spec player(t, Player.id()) :: Player.t()
  defp player(game_state, player_id) do
    Map.fetch!(game_state.players, player_id)
  end

  @spec matchup_player_id(t, Player.id()) :: Player.id()
  def matchup_player_id(game_state, player_id) do
    Map.fetch!(game_state.matchups, player_id)
  end

  defp matchup_player(game_state, player_id) do
    defender_id = matchup_player_id(game_state, player_id)
    player(game_state, defender_id)
  end

  def shot_clock_seconds, do: @shot_clock_seconds

  @spec remaining_time(t) :: non_neg_integer
  def remaining_time(game_state) do
    min(game_state.clock_seconds, game_state.shot_clock)
  end

  defp set_court(home_squad = %{players: home}, road_squad = %{players: road}) do
    home_squad = %Squad{home_squad | players: your_court(home, :home)}
    road_squad = %Squad{road_squad | players: your_court(road, :road)}

    {home_squad, road_squad}
  end

  defp your_court(players, court) do
    Enum.map(players, fn player -> %Player{player | team: court} end)
  end

  defp players_map(one_squad, another_squad) do
    (one_squad.players ++ another_squad.players)
    |> Enum.map(fn player -> {player.id, player} end)
    |> Map.new()
  end

  defp assign_matchups(one_squad, another_squad) do
    (one_squad.lineup ++ another_squad.lineup)
    |> Enum.zip(another_squad.lineup ++ one_squad.lineup)
    |> Map.new()
  end
end
