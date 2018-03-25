defmodule BBEngine.BoxScore.Statistics do

  defstruct [
    points: 0,
    field_goals_made: 0,
    field_goals_attempted: 0,
    offensive_rebounds: 0,
    defensive_rebounds: 0,
    rebounds: 0
  ]

  @type t :: %__MODULE__{
    points: non_neg_integer,
    field_goals_made: non_neg_integer,
    field_goals_attempted: non_neg_integer,
    offensive_rebounds: non_neg_integer,
    defensive_rebounds: non_neg_integer,
    rebounds: non_neg_integer
  }
  
  alias BBEngine.Events.Rebound
  alias BBEngine.Events.Shot

  def apply(statistics, event)
  def apply(statistics, %Rebound{type: :defensive}) do
    %__MODULE__{
      statistics |
      defensive_rebounds: statistics.defensive_rebounds + 1,
      rebounds: statistics.rebounds + 1
    }
  end

  def apply(statistics, %Rebound{type: :offensive}) do
    %__MODULE__{
      statistics |
      offensive_rebounds: statistics.offensive_rebounds + 1,
      rebounds: statistics.rebounds + 1
    }
  end

  def apply(statistics, %Shot{success: true}) do
    %__MODULE__{
      statistics |
      points: statistics.points + 2,
      field_goals_attempted: statistics.field_goals_attempted + 1,
      field_goals_made: statistics.field_goals_made + 1,
    }
  end
  
  def apply(statistics, %Shot{success: false}) do
    %__MODULE__{
      statistics |
      field_goals_attempted: statistics.field_goals_attempted + 1
    }
  end
end
