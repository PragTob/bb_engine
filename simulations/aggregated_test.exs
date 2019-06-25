alias BBEngine.Player
alias BBEngine.Squad
alias BBEngine.Simulation
alias BBEngine.BoxScoreAggregator

home_players = Enum.map(1..12, &Player.standard_player/1)
road_players = Enum.map(13..24, &Player.standard_player/1)

home_squad = %Squad{
  players: home_players,
  lineup: [1, 2, 3, 4, 5],
  bench: Enum.to_list(6..12)
}

road_squad = %Squad{
  players: road_players,
  lineup: [13, 14, 15, 16, 17],
  bench: Enum.to_list(18..25)
}

box_score =
  1..1_000
  |> Enum.map(fn i ->
    if rem(i, 100) == 0, do: IO.puts("Simulation #{i}")
    Simulation.simulate(home_squad, road_squad).box_score
  end)
  |> BoxScoreAggregator.aggregate()

IO.puts("------------------HOME---------------------")
IO.inspect(box_score.home.team)
IO.puts("------------------ROAD---------------------")
IO.inspect(box_score.road.team)
