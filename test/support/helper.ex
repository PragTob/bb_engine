defmodule BBEngine.TestHelper do
  alias BBEngine.{GameState, Player, Random, Squad}

  @home_squad %Squad{
    players: Enum.map(1..12, &Player.standard_player/1),
    lineup: [1, 2, 3, 4, 5]
  }
  @road_squad %Squad{
    players: Enum.map(13..24, &Player.standard_player/1),
    lineup: [13, 14, 15, 16, 17]
  }
  @ball_handler_id 1

  def home_squad, do: @home_squad

  def road_squad, do: @road_squad

  def build_game_state(override) do
    game_state =
      @home_squad
      |> GameState.new(@road_squad, Random.seed())
      |> Map.put(:ball_handler_id, @ball_handler_id)
      |> Map.put(:possession, :home)

    Map.merge(game_state, override)
  end
end
