defmodule BBEngine.Player do
  # attributes
  # offensive/defensive capabilities
  defstruct [
    :id,
    :offensive_rating,
    :defensive_rating,
    :offensive_rebound,
    :defensive_rebound,
    :team
  ]

  def standard_player(id) do
    %__MODULE__{
      id: id,
      offensive_rating: 50,
      defensive_rating: 50,
      offensive_rebound: 30,
      defensive_rebound: 70
    }
  end
end
