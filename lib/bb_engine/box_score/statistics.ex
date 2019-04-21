defmodule BBEngine.BoxScore.Statistics do
  defstruct points: 0,
            field_goals_made: 0,
            field_goals_attempted: 0,
            two_points_made: 0,
            two_points_attempted: 0,
            three_points_made: 0,
            three_points_attempted: 0,
            blocks: 0,
            blocked_shots: 0,
            offensive_rebounds: 0,
            defensive_rebounds: 0,
            rebounds: 0,
            steals: 0,
            turnovers: 0

  @type t :: %__MODULE__{
          points: non_neg_integer,
          field_goals_made: non_neg_integer,
          field_goals_attempted: non_neg_integer,
          two_points_made: non_neg_integer,
          two_points_attempted: non_neg_integer,
          three_points_made: non_neg_integer,
          three_points_attempted: non_neg_integer,
          blocks: non_neg_integer,
          blocked_shots: non_neg_integer,
          offensive_rebounds: non_neg_integer,
          defensive_rebounds: non_neg_integer,
          rebounds: non_neg_integer,
          steals: non_neg_integer,
          turnovers: non_neg_integer
        }

  @doc """
  Return all the different statistics we track.
  """
  @spec stats() :: [atom]
  def stats do
    %__MODULE__{}
    |> Map.from_struct()
    |> Map.keys()
  end
end
