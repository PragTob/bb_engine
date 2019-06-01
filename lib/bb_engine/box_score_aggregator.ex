defmodule BBEngine.BoxScoreAggregator do
  alias BBEngine.BoxScore
  alias BBEngine.BoxScore.Statistics

  @spec aggregate([BoxScore.t()]) :: %{
          home: BoxScore.squad_statistics(),
          road: BoxScore.squad_statistics()
        }
  def aggregate(box_scores) do
    n = length(box_scores)

    %{
      home: aggregate(Enum.map(box_scores, fn score -> score.home end), n),
      road: aggregate(Enum.map(box_scores, fn score -> score.road end), n)
    }
  end

  @spec aggregate([BoxScore.squad_statistics()], pos_integer) :: BoxScore.squad_statistics()
  defp aggregate(scores, n) do
    scores
    |> Enum.reduce(fn statistics, acc -> aggregate_statistics(statistics, acc, n) end)
    # |> Enum.map(fn {key, stats} -> {key, adjust_stats(stats, n)} end)
    |> Map.new()
  end

  @spec aggregate_statistics(
          BoxScore.squad_statistics(),
          BoxScore.squad_statistics(),
          pos_integer
        ) ::
          BoxScore.squad_statistics()
  defp aggregate_statistics(statistics, acc, count) do
    statistics
    |> Enum.map(fn {id, stats} ->
      {id, add_individual_statistics(stats, acc[id], count)}
    end)
    |> Map.new()
  end

  @spec add_individual_statistics(
          BoxScore.individual_statistics(),
          BoxScore.individual_statistics(),
          pos_integer
        ) :: BoxScore.individual_statistics()
  defp add_individual_statistics(statistics, acc, count) do
    statistics
    |> Enum.map(fn {time, stats} ->
      {time, add_statistics(stats, Map.get(acc, time, %Statistics{}))}
    end)
    |> Enum.map(fn {key, stats} -> {key, adjust_stats(stats, count)} end)
    |> Map.new()
  end

  @spec add_statistics(Statistics.t(), Statistics.t()) :: Statistics.t()
  defp add_statistics(stats1, stats2) do
    Statistics.stats()
    |> Enum.map(fn entry -> {entry, Map.fetch!(stats1, entry) + Map.fetch!(stats2, entry)} end)
    |> Map.new()
  end

  defp adjust_stats(statistics, n) do
    stats =
      statistics
      |> Enum.map(fn {key, value} -> {key, value / n} end)
      |> Map.new()

    struct(Statistics, stats)
  end
end
