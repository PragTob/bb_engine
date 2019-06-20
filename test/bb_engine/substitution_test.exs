defmodule BBEngine.SubstitutionTest do
  use ExUnit.Case, async: true
  alias BBEngine.{Player, Squad, Substitution, TestHelper}
  import BBEngine.Substitution

  describe ".force_substitute" do
    test "substituting players" do
      squad = %Squad{
        players: Enum.map(1..12, &Player.standard_player/1),
        lineup: [1, 2, 3, 4, 5],
        bench: Enum.to_list(6..12)
      }

      game_state =
        TestHelper.build_game_state(%{
          home: squad,
          matchups: %{3 => 8, 9 => 3}
        })

      # 6 is the ecxpected substitute with the current easy
      # first bench player substitution

      game_state = force_substitute(game_state, :home, 3)
      assert game_state.matchups == %{6 => 8, 9 => 6}
      assert [%Substitution{to_substitute_id: 3, substitute_id: 6} | _] = game_state.events

      home_squad = game_state.home
      assert home_squad.lineup == [1, 2, 6, 4, 5]
      assert home_squad.ineligible == [3]
      refute 3 in home_squad.bench
    end
  end
end
