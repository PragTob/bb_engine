alias BBEngine.Player
alias BBEngine.Squad
alias BBEngine.Simulation

home_players = Enum.map((1..12),
  fn(id) -> %Player{id: id, offensive_rating: 50, defensive_rating: 50} end)
road_players = Enum.map((13..24),
  fn(id) -> %Player{id: id, offensive_rating: 50, defensive_rating: 50} end)
home_squad = %Squad{
  players: home_players,
  lineup: [1, 2, 3, 4, 5]
}
road_squad = %Squad{
  players: road_players,
  lineup: [13, 14, 15, 16, 17]
}

game_state = Simulation.simulate(home_squad, road_squad)
IO.inspect(game_state.box_score.team)
