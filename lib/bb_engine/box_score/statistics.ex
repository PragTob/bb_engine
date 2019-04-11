defmodule BBEngine.BoxScore.Statistics do
  alias BBEngine.Event
  alias BBEngine.Event.{Turnover, Rebound, Shot}

  defstruct points: 0,
            field_goals_made: 0,
            field_goals_attempted: 0,
            two_points_made: 0,
            two_points_attempted: 0,
            three_points_made: 0,
            three_points_attempted: 0,
            offensive_rebounds: 0,
            defensive_rebounds: 0,
            rebounds: 0,
            turnovers: 0

  @type t :: %__MODULE__{
          points: non_neg_integer,
          field_goals_made: non_neg_integer,
          field_goals_attempted: non_neg_integer,
          two_points_made: non_neg_integer,
          two_points_attempted: non_neg_integer,
          three_points_made: non_neg_integer,
          three_points_attempted: non_neg_integer,
          offensive_rebounds: non_neg_integer,
          defensive_rebounds: non_neg_integer,
          rebounds: non_neg_integer,
          turnovers: non_neg_integer
        }

  def stats do
    %__MODULE__{}
    |> Map.from_struct()
    |> Map.keys()
  end

  @spec apply(t, Event.t()) :: t
  def apply(statistics, event)

  def apply(statistics, %Rebound{type: :defensive}) do
    %__MODULE__{
      statistics
      | defensive_rebounds: statistics.defensive_rebounds + 1,
        rebounds: statistics.rebounds + 1
    }
  end

  def apply(statistics, %Rebound{type: :offensive}) do
    %__MODULE__{
      statistics
      | offensive_rebounds: statistics.offensive_rebounds + 1,
        rebounds: statistics.rebounds + 1
    }
  end

  def apply(statistics, shot = %Shot{success: true, points: 2}) do
    %__MODULE__{
      statistics
      | points: statistics.points + shot.points,
        field_goals_attempted: statistics.field_goals_attempted + 1,
        field_goals_made: statistics.field_goals_made + 1,
        two_points_attempted: statistics.two_points_attempted + 1,
        two_points_made: statistics.two_points_made + 1
    }
  end

  def apply(statistics, shot = %Shot{success: true, points: 3}) do
    %__MODULE__{
      statistics
      | points: statistics.points + shot.points,
        field_goals_attempted: statistics.field_goals_attempted + 1,
        field_goals_made: statistics.field_goals_made + 1,
        three_points_attempted: statistics.three_points_attempted + 1,
        three_points_made: statistics.three_points_made + 1
    }
  end

  def apply(statistics, %Shot{success: false, points: 2}) do
    %__MODULE__{
      statistics
      | field_goals_attempted: statistics.field_goals_attempted + 1,
        two_points_attempted: statistics.two_points_attempted + 1
    }
  end

  def apply(statistics, %Shot{success: false, points: 3}) do
    %__MODULE__{
      statistics
      | field_goals_attempted: statistics.field_goals_attempted + 1,
        three_points_attempted: statistics.three_points_attempted + 1
    }
  end

  def apply(statistics, %Turnover{}) do
    %__MODULE__{
      statistics
      | turnovers: statistics.turnovers + 1
    }
  end

  # we don't count/apply individual passes atm
  def apply(statistics, _unrecognized_event), do: statistics
end
