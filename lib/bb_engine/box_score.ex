defmodule BBEngine.BoxScore do
  alias BBEngine.BoxScore.Statistics

  defstruct [
    :home,
    :road
  ]

  @type t :: %{home: map, road: map}

  @behaviour Access

  defdelegate fetch(term, key), to: Map
  defdelegate get(term, key, default), to: Map
  defdelegate get_and_update(data, key, function), to: Map
  defdelegate pop(data, key), to: Map

  alias BBEngine.BoxScore.Statistics

  def new(home_squad, away_squad) do
    %__MODULE__{
      home: statistics(home_squad),
      road: statistics(away_squad)
    }
  end

  def update(box_score, event = %{team: team, actor_id: actor_id}) do
    squad_box_score = Map.fetch! box_score, team
    individual_box_score = Statistics.apply(squad_box_score[actor_id], event)
    team_box_score = Statistics.apply(squad_box_score[:team], event)
    updated_squad_box_score = %{
      squad_box_score |
      actor_id => individual_box_score,
      team: team_box_score
    }
    %{box_score | team => updated_squad_box_score}
  end
  # We currently ignore the possession switch... we could count them but does
  # that interest anyone?
  def update(box_score, _event_without_actors), do: box_score

  defp statistics(squad) do
    player_stats = Enum.map(squad.players, fn player -> {player.id, %Statistics{}} end)
    Map.new([{:team, %Statistics{}} | player_stats])
  end
end
