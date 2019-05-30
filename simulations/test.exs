alias BBEngine.Player
alias BBEngine.Squad
alias BBEngine.Simulation

home_players = Enum.map(1..12, &Player.standard_player/1)
road_players = Enum.map(13..24, &Player.standard_player/1)

home_squad = %Squad{
  players: home_players,
  lineup: [1, 2, 3, 4, 5]
}

road_squad = %Squad{
  players: road_players,
  lineup: [13, 14, 15, 16, 17]
}

game_state = Simulation.simulate(home_squad, road_squad)
IO.puts("------------------HOME---------------------")
IO.inspect(game_state.box_score.home.team)
IO.puts("------------------ROAD---------------------")
IO.inspect(game_state.box_score.road.team)

IO.puts("\nEvent distribution:")

distribution =
  game_state.events
  |> Enum.group_by(fn event -> event.__struct__ end)
  |> Enum.map(fn {key, values} -> {key, length(values)} end)
  |> Map.new()

IO.inspect(distribution)

IO.puts("\nEvent count: #{length(game_state.events)}")

defmodule MemoryPrinter do
  @word_size :erlang.system_info(:wordsize)
  def print(name, term) do
    size = :erts_debug.size(term)
    flat_size = :erts_debug.flat_size(term)
    IO.puts("size of #{name}: #{size * @word_size / 1024} kilobytes")
    IO.puts("flat_size of #{name}: #{flat_size * @word_size / 1024} kilobytes")
  end
end

MemoryPrinter.print("game state", game_state)
MemoryPrinter.print("box_score", game_state.box_score)
MemoryPrinter.print("events", game_state.events)
