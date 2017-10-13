defmodule BBEngine.BoxScore do
  alias BBEngine.BoxScore.Statistics

  defstruct [
    :individual,
    :team
  ]

  alias BBEngine.BoxScore.Statistics

  def new(home_squad, away_squad) do
    %__MODULE__{
      team: team_box_scores(),
      individual: player_box_scores(home_squad, away_squad)
    }
  end

  defp team_box_scores do
    %{
      home: %Statistics{},
      road: %Statistics{}
    }
  end

  defp player_box_scores(one_squad, another_squad) do
    (one_squad.players ++ another_squad.players)
    |> Enum.map(fn(player) -> {player.id, %Statistics{}} end)
    |> Map.new
  end
end
