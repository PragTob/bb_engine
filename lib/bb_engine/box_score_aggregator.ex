defmodule BBEngine.BoxScoreAggregator do
  alias BBEngine.BoxScore
  alias BBEngine.BoxScore.Statistics

  @spec aggregate([BoxScore.t]) :: BoxScore.t
  def aggregate(box_scores) do
    n = length(box_scores)
    %BoxScore{
      home: aggregate(Enum.map(box_scores, fn score -> score.home  end), n),
      road: aggregate(Enum.map(box_scores, fn score -> score.road  end), n)
    }
  end

  @spec aggregate([BoxScore.squad_statistics], non_neg_integer) :: BoxScore.squad_statistics
  defp aggregate(scores, n) do
    scores
    |> Enum.reduce(fn statistics, acc -> aggregate_statistics(statistics, acc) end)
    |> Enum.map(fn {key, stats} -> {key, adjust_stats(stats, n)} end)
    |> Map.new
  end

  defp aggregate_statistics(statistics, acc) do
    statistics
    |> Enum.map(fn {id, stats} -> {id, add_statistics(stats, acc[id])} end)
    |> Map.new
  end

  defp adjust_stats(statistics, n) do
    stats =
      statistics
      |> Enum.map(fn {key, value} -> {key, value / n} end)
      |> Map.new

    struct(Statistics, stats)
  end

  defp get_statistics_entries do
    %Statistics{}
    |> Map.from_struct
    |> Map.keys
  end

  defp add_statistics(stats1, stats2) do
    get_statistics_entries()
    |> Enum.map(fn(entry) -> {entry, Map.fetch!(stats1, entry) + Map.fetch!(stats2, entry)} end)
    |> Map.new
  end
end
