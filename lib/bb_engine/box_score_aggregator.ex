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
  defp aggregate(squad_statistics, count) do
    squad_statistics
    |> Enum.reduce(fn squad_stat, acc -> aggregate_statistics(squad_stat, acc) end)
    |> Enum.map(fn {id, stats} -> {id, adjust_player_stats_for_repetition(stats, count)} end)
    |> Map.new()
  end

  @spec aggregate_statistics(
          BoxScore.squad_statistics(),
          BoxScore.squad_statistics()
        ) ::
          BoxScore.squad_statistics()
  defp aggregate_statistics(statistics, acc) do
    statistics
    |> Enum.map(fn {id, stats} ->
      {id, add_individual_statistics(stats, acc[id])}
    end)
    |> Map.new()
  end

  @spec add_individual_statistics(
          BoxScore.individual_statistics(),
          BoxScore.individual_statistics()
        ) :: BoxScore.individual_statistics()
  defp add_individual_statistics(statistics, acc) do
    statistics
    |> Enum.map(fn {time, stats} ->
      {time, add_statistics(stats, Map.get(acc, time, %Statistics{}))}
    end)
    |> Map.new()
  end

  @spec add_statistics(Statistics.t(), Statistics.t()) :: Statistics.t()
  defp add_statistics(stats1, stats2) do
    Statistics.stats()
    |> Enum.map(fn entry -> {entry, Map.fetch!(stats1, entry) + Map.fetch!(stats2, entry)} end)
    |> Map.new()
  end

  defp adjust_player_stats_for_repetition(player_stats, count) do
    player_stats
    |> Enum.map(fn {key, time_stats} -> {key, adjust_stats(time_stats, count)} end)
    |> Map.new()
  end

  defp adjust_stats(statistics, count) do
    stats =
      statistics
      |> Enum.map(fn {key, value} -> {key, value / count} end)
      |> Map.new()

    struct(Statistics, stats)
  end
end
