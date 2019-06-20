defmodule GameViewerTest do
  use ExUnit.Case, async: true

  alias BBEngine.Player
  alias BBEngine.Squad
  alias BBEngine.GameViewer

  import ExUnit.CaptureIO

  test "does not blow up" do
    home_players = Enum.map(1..12, &Player.standard_player/1)
    road_players = Enum.map(13..24, &Player.standard_player/1)

    home_squad = %Squad{
      players: home_players,
      lineup: [1, 2, 3, 4, 5],
      bench: Enum.to_list(6..12)
    }

    road_squad = %Squad{
      players: road_players,
      lineup: [13, 14, 15, 16, 17],
      bench: Enum.to_list(18..25)
    }

    capture_io(fn -> GameViewer.simulate(home_squad, road_squad) end)
  end
end
