defmodule BBEngine.Event.StealTest do
  use ExUnit.Case, async: true

  alias BBEngine.Event.Steal
  alias BBEngine.TestHelper

  import BBEngine.Event.Steal

  describe "update_game_state/2" do
    test "changes possession" do
      gs = TestHelper.build_game_state(%{ball_handler_id: 1, possession: :home})

      event = %Steal{
        actor_id: 17,
        stolen_from: 1,
        team: :road,
        duration: 2
      }

      gs = update_game_state(gs, event)

      assert gs.ball_handler_id == 17
      assert gs.possession == :road
    end

    test "updates statistics correctly for both involved players" do
      gs = TestHelper.build_game_state(%{ball_handler_id: 1, possession: :home})

      event = %Steal{
        actor_id: 17,
        stolen_from: 1,
        team: :road,
        duration: 2
      }

      gs = update_game_state(gs, event)

      assert gs.box_score.road[17].steals == 1
      assert gs.box_score.home[1].turnovers == 1
    end
  end
end
