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

Benchee.run(
  %{
    "basic simulation" => fn ->
      Simulation.simulate(home_squad, road_squad)
    end
  },
  formatters: [{Benchee.Formatters.Console, extended_statistics: true}],
  memory_time: 3
)
<<<<<<< HEAD
=======

# Operating System: Linux
# CPU Information: Intel(R) Core(TM) i7-4790 CPU @ 3.60GHz
# Number of Available Cores: 8
# Available memory: 15.61 GB
# Elixir 1.8.1
# Erlang 21.3.2

# Benchmark suite executing with the following configuration:
# warmup: 2 s
# time: 5 s
# memory time: 3 s
# parallel: 1
# inputs: none specified
# Estimated total run time: 10 s

# Benchmarking basic simulation...

# Name                       ips        average  deviation         median         99th %
# basic simulation        304.14        3.29 ms     ±6.48%        3.25 ms        3.96 ms

# Extended statistics:

# Name                     minimum        maximum    sample size                     mode
# basic simulation         2.98 ms        6.09 ms         1.52 K                  3.22 ms

# Memory usage statistics:

# Name                     average  deviation         median         99th %
# basic simulation         2.73 MB     ±2.53%        2.72 MB        3.08 MB

# Extended statistics:

# Name                     minimum        maximum    sample size                     mode
# basic simulation         2.59 MB        3.44 MB            6942.73 MB, 2.74 MB, 2.73 MB
>>>>>>> aac0c37... wip
