defmodule BBEngine.PlayerTest do
  use ExUnit.Case, async: true
  import BBEngine.Player

  alias BBEngine.Player

  describe ".skill_map/2" do
    test "map from player to the respective skill" do
      one = %Player{id: 1, offensive_rating: 50}
      two = %Player{id: 2, offensive_rating: 80}
      assert %{^one => 50, ^two => 80} = skill_map([one, two], :offensive_rating)
    end
  end
end
