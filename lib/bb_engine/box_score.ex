defmodule BBEngine.BoxScore do
  alias BBEngine.BoxScore.Statistics
  alias BBEngine.Possession
  alias BBEngine.Player
  alias BBEngine.Squad

  @shot_clock_seconds 24
  @minutes_per_quarter 10
  @seconds_per_quarter 60 * @minutes_per_quarter

  defstruct [
    :home,
    :road,
    :quarter,
    :clock_seconds,
    shot_clock: @shot_clock_seconds
  ]

  @typedoc """
  Most importantly holds both the road and home squad statistics.

  More interestingly holds quarter and clock seconds data. That used to be in GameState but
  when wanting to keep quarterly statistics it's way more convenient data to have it here.
  Also this way GameState holds only "internal" (save for the events) while BoxScore has
  data to be transmitted and shown to the client.
  """
  @type t :: %__MODULE__{
          home: squad_statistics,
          road: squad_statistics,
          quarter: pos_integer,
          clock_seconds: non_neg_integer,
          shot_clock: non_neg_integer
        }
  @type individual_statistics :: %{:total => Statistics.t(), pos_integer => Statistics.t()}
  @type squad_statistics :: %{(:team | Player.id()) => individual_statistics}

  @behaviour Access

  defdelegate fetch(term, key), to: Map
  defdelegate get(term, key, default), to: Map
  defdelegate get_and_update(data, key, function), to: Map
  defdelegate pop(data, key), to: Map

  @spec new(Squad.t(), Squad.t()) :: t
  def new(home_squad, away_squad) do
    %__MODULE__{
      home: statistics(home_squad),
      road: statistics(away_squad),
      quarter: 1,
      clock_seconds: @seconds_per_quarter,
      shot_clock: @shot_clock_seconds
    }
  end

  defp statistics(squad) do
    player_stats = Enum.map(squad.players, fn player -> {player.id, base_statistics()} end)
    Map.new([{:team, base_statistics()} | player_stats])
  end

  # keys are quarters or the total
  defp base_statistics do
    %{
      1 => %Statistics{},
      2 => %Statistics{},
      3 => %Statistics{},
      4 => %Statistics{},
      total: %Statistics{}
    }
  end

  def shot_clock_seconds, do: @shot_clock_seconds
  @spec seconds_per_quarter() :: 600
  def seconds_per_quarter, do: @seconds_per_quarter

  @final_quarter 4
  def final_quarter, do: @final_quarter

  @spec remaining_time(t) :: non_neg_integer
  def remaining_time(box_score) do
    min(box_score.clock_seconds, box_score.shot_clock)
  end

  @type update_function :: (Statistics.t() -> Statistics.t())
  @spec update(t, Possession.t(), Player.id(), update_function) :: t
  def update(box_score, team, player_id, statistics_update_function) do
    quarter = box_score.quarter

    box_score
    |> update_in([team, player_id, quarter], statistics_update_function)
    |> update_in([team, player_id, :total], statistics_update_function)
    |> update_in([team, :team, quarter], statistics_update_function)
    |> update_in([team, :team, :total], statistics_update_function)
  end

  @spec advance_quarter(BBEngine.BoxScore.t()) :: BBEngine.BoxScore.t()
  def advance_quarter(box_score) do
    new_quarter = box_score.quarter + 1

    %__MODULE__{
      box_score
      | quarter: new_quarter,
        clock_seconds: quarter_seconds(new_quarter),
        shot_clock: shot_clock_seconds(),
        home: extend_statistics(box_score.home, new_quarter),
        road: extend_statistics(box_score.road, new_quarter)
    }
  end

  @seconds_per_overtime 5 * 60
  defp quarter_seconds(quarter) when quarter <= @final_quarter, do: @seconds_per_quarter
  defp quarter_seconds(_quarter), do: @seconds_per_overtime

  # When hitting over time we need to provide new statistics for those quarters,
  # as `base_statistics/0` only generates it for the first 4 quarters.
  @spec extend_statistics(squad_statistics, pos_integer) :: squad_statistics
  defp extend_statistics(squad_stats, quarter) when quarter <= 4 do
    squad_stats
  end

  defp extend_statistics(squad_stats, quarter) do
    squad_stats
    |> Enum.map(fn {identifier, individual_statistics} ->
      {identifier, Map.put_new(individual_statistics, quarter, %Statistics{})}
    end)
    |> Map.new()
  end

  @spec tie?(t) :: bool
  def tie?(box_score) do
    box_score.home.team.total.points == box_score.road.team.total.points
  end
end
