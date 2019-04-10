algorithms = [:exs64, :exsplus, :exsp, :exs1024, :exs1024s, :exrop]

jobs =
  Enum.map(algorithms, fn algorithm ->
    {
      "#{algorithm} uniform",
      {
        fn n -> :rand.uniform(n) end,
        before_scenario: fn n ->
          :rand.seed(algorithm)
          n
        end
      }
    }
  end)

inputs = %{
  "100" => 100,
  "10_000" => 10_000
}

Benchee.run(
  jobs,
  formatters: [{Benchee.Formatters.Console, extended_statistics: true}],
  inputs: inputs,
  time: 2,
  warmup: 1
)
