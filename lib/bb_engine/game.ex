defmodule BBEngine.GameState do
  # quarter
  # clock
  # score
  # statistics?

  defstruct [
    :quarter,
    :clock_seconds,
    :ball_handler_id,
    :box_score,
    :home,
    :road,
    :events,
    :players,
    :matchups,
    :initial_seed,
    :current_seed
  ]
end

defmodule BBEngine.BoxScore.Statistics do
  defstruct [
    points: 0,
    field_goals_made: 0,
    field_goals_attempted: 0
  ]

end

defmodule BBEngine.BoxScore do
  defstruct [
    :individual,
    :team
  ]

  alias BBEngine.BoxScore.Statistics

  def new(home_squad, away_squad) do
    %__MODULE__{
      team: team_box_scores(),
      individual: player_box_scores(home_squad, away_squad)
    }
  end

  defp team_box_scores do
    %{
      home: %Statistics{},
      road: %Statistics{}
    }
  end

  defp player_box_scores(one_squad, another_squad) do
    (one_squad.players ++ another_squad.players)
    |> Enum.map(fn(player) -> {player.id, %Statistics{}} end)
    |> Map.new
  end
end

defmodule BBEngine.Squad do
  defstruct [
    :lineup,
    :bench,
    :players
  ]
end

defmodule BBEngine.Player do
  # attributes
  # offensive/defensive capabilities
  defstruct [
    :id,
    :offensive_rating,
    :defensive_rating,
    :court
  ]
end

defmodule BBEngine.Simulation do
  alias BBEngine.GameState
  alias BBEngine.BoxScore
  alias BBEngine.Squad
  alias BBEngine.Player
  alias BBEngine.Actions

  @minutes_per_quarter 10
  @seconds_per_quarter 60 * @minutes_per_quarter
  def simulate(home_squad, road_squad, seed \\ :rand.seed_s(:exrop)) do
    {home_squad, road_squad} = set_court(home_squad, road_squad)
    game_state = %GameState{
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

    game_state = jump_ball(game_state)

    # home court advantage?

    simulate_event(game_state)

    # over time?

  end

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

  defp jump_ball(game_state) do
    # of course get a correct jumpball going here
    new_ball_handler = Enum.random game_state.home.lineup
    %GameState{game_state | ball_handler_id: new_ball_handler}
  end

  @final_quarter 4
  def simulate_event(game_state = %GameState{quarter: @final_quarter, clock_seconds: clocks_seconds})
         when clocks_seconds <= 0 do
    game_state
  end
  def simulate_event(game_state = %GameState{quarter: quarter, clock_seconds: clocks_seconds})
         when clocks_seconds <= 0 do
    # Do substitutions etc.
    simulate_event(%GameState{ game_state | quarter: quarter + 1,
                                            clock_seconds: @seconds_per_quarter})
  end
  def simulate_event(game_state = %GameState{clock_seconds: time}) do
    new_game_state = game_state
                     |> determine_action
                     |> play_action(game_state)

    # TBD
    elapsed_time = 10 + :rand.uniform(14)
    simulate_event %GameState{new_game_state | clock_seconds: time - elapsed_time}
  end

  defp determine_action(_game_state) do
    Actions.TwoPointShot
  end

  defp play_action(action_module, game_state) do
    action_module.play game_state
  end
end
