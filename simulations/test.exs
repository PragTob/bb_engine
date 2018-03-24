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

game_state = Simulation.simulate(home_squad, road_squad)
IO.inspect(game_state.box_score.home.team)
IO.inspect(game_state.box_score.road.team)

