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

  # Inside Scoring
  # Mid Range Scoring
  # 3 Pt Outside Scoring
  # Perimeter Defense
  # Inside Defense -- no mid defense? What will be used for mid range shots
  # Athleticism
  # Speed
  # Dribbling
  # Rebounds
  # Footwork?
  # passing
  # Experience

  @type id :: integer

  @type t :: %__MODULE__{
          id: id,
          offensive_rating: number,
          defensive_rating: number,
          offensive_rebound: number,
          defensive_rebound: number,
          team: :home | :road
        }

  @type skill :: :offensive_rating | :defensive_rating | :offensive_rebound | :defensive_rebound

  @spec skill_map([t], skill) :: %{t => number}
  def skill_map(players, skill) do
    Enum.reduce(players, %{}, fn player = %{^skill => value}, map ->
      Map.put_new(map, player, value)
    end)
  end

  def standard_player(id) do
    %__MODULE__{
      id: id,
      offensive_rating: 50,
      defensive_rating: 50,
      offensive_rebound: 30,
      defensive_rebound: 70,
      team: :home
    }
  end
end
