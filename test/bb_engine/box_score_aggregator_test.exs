defmodule BBEngine.BoxScoreAggregatorTest do
  use ExUnit.Case, async: true

  alias BBEngine.BoxScore
  alias BBEngine.Player
  alias BBEngine.Squad

  import BBEngine.BoxScoreAggregator

  @box_score BoxScore.new(
               %Squad{players: [Player.standard_player(1)]},
               %Squad{players: []}
             )
  test "aggregates scores just fine in a simple scenario" do
    score_1 =
      @box_score
      |> BoxScore.update(:home, 1, fn stats ->
        put_in(stats.points, 2)
      end)

    score_2 =
      BoxScore.update(@box_score, :home, 1, fn stats ->
        put_in(stats.points, 10)
      end)

    result = aggregate([score_1, score_2])

    assert result.home.team.total.points == 6.0
    assert result.home.team[1].points == 6.0

    assert result.road.team.total.points == 0.0
  end

  test "aggregates 10 box scores just fine" do
    score =
      @box_score
      |> BoxScore.update(:home, 1, fn stats ->
        put_in(stats.points, 2)
      end)

    result = aggregate(Enum.map(1..10, fn _ -> score end))

    assert result.home.team.total.points == 2.0
    assert result.home.team[1].points == 2.0

    assert result.road.team.total.points == 0.0
  end
end
