alias BBEngine.Player
alias BBEngine.Squad
alias BBEngine.Simulation

home_players = Enum.map((1..12), &Player.standard_player/1)
road_players = Enum.map((13..24), &Player.standard_player/1)
home_squad = %Squad{
  players: home_players,
  lineup: [1, 2, 3, 4, 5]
}
road_squad = %Squad{
  players: road_players,
  lineup: [13, 14, 15, 16, 17]
}

n = 100
{home, road} =
  1..100
  |> Enum.map(fn _ -> Simulation.simulate(home_squad, road_squad) end)
  |> Enum.reduce({0, 0}, fn game, {home_score, away_score} ->
       box_score = game.box_score.team
       {home_score + box_score.home.points, away_score + box_score.road.points }
     end)
IO.puts "home: #{home / n}, road: #{road / n}"