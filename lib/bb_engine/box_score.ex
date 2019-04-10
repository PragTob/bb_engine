defmodule BBEngine.BoxScore do
  alias BBEngine.BoxScore
  alias BBEngine.BoxScore.Statistics
  alias BBEngine.Event
  alias BBEngine.Player
  alias BBEngine.Squad

  defstruct [
    :home,
    :road
  ]

  @type t :: %__MODULE__{
          home: squad_statistics,
          road: squad_statistics
        }
  @type squad_statistics :: %{(:team | Player.id()) => Statistics.t()}

  @behaviour Access

  defdelegate fetch(term, key), to: Map
  defdelegate get(term, key, default), to: Map
  defdelegate get_and_update(data, key, function), to: Map
  defdelegate pop(data, key), to: Map

  @spec new(Squad.t(), Squad.t()) :: t
  def new(home_squad, away_squad) do
    %__MODULE__{
      home: statistics(home_squad),
      road: statistics(away_squad)
    }
  end

  @spec update(t, Event.t()) :: t
  def update(box_score, event = %{team: team, actor_id: actor_id}) do
    box_score
    |> update_in([team, actor_id], fn stats -> Statistics.apply(stats, event) end)
    |> update_in([team, :team], fn stats -> Statistics.apply(stats, event) end)
  end

  # We currently ignore the possession switch... we could count them but does
  # that interest anyone?
  def update(box_score, _event_without_actors), do: box_score

  defp statistics(squad) do
    player_stats = Enum.map(squad.players, fn player -> {player.id, %Statistics{}} end)
    Map.new([{:team, %Statistics{}} | player_stats])
  end

  @spec tie?(t) :: bool
  def tie?(box_score) do
    box_score.home.team.points == box_score.road.team.points
  end
end
