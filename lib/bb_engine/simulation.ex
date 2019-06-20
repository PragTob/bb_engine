defmodule BBEngine.Simulation do
  alias BBEngine.{ActionChooser, GameState, Random, Event, BoxScore, Squad, Substitution}

  @spec new(Squad.t(), Squad.t(), Random.state()) :: GameState.t()
  def new(home_squad, road_squad, seed \\ Random.seed()) do
    # home court advantage?
    home_squad
    |> GameState.new(road_squad, seed)
    |> jump_ball
  end

  @spec simulate(Squad.t(), Squad.t(), Random.state()) :: GameState.t()
  def simulate(home_squad, road_squad, seed \\ Random.seed()) do
    home_squad
    |> new(road_squad, seed)
    |> run_simulation
  end

  defp jump_ball(game_state) do
    # of course get a correct jumpball going here
    {new_game_state, winner} = Random.list_element(game_state, game_state.home.lineup)
    %GameState{new_game_state | ball_handler_id: winner, possession: :home}
  end

  @doc """
  Will run the simulation until the game is finished.
  """
  @spec run_simulation(GameState.t()) :: GameState.t()
  def run_simulation(game_state = %GameState{events: [%Event.GameFinished{} | _]}) do
    game_state
  end

  def run_simulation(game_state) do
    game_state
    |> advance_simulation
    |> run_simulation
  end

  @doc """
  Advances the simulation one step/action at a time.
  """
  def advance_simulation(game_state) do
    # we could check for an expired shot clock here and only determine actions etc.
    # if the shot clock isn't expired but that'd double the check with after the action
    # was taken for probably not too many winnings.
    game_state
    |> ActionChooser.next_action()
    |> simulate_action()
  end

  @spec simulate_action({GameState.t(), module}) :: GameState.t()
  def simulate_action({game_state, action_module}) do
    game_state
    |> action_module.play
    |> catch_time_violations
    |> apply_event
    |> trigger_off_the_court_actions
  end

  defp catch_time_violations({game_state, event}) do
    event_happening =
      if event.duration > game_state.box_score.clock_seconds do
        if finished?(game_state) do
          %Event.GameFinished{duration: game_state.box_score.clock_seconds}
        else
          %Event.EndOfQuarter{duration: game_state.box_score.clock_seconds}
        end
      else
        # happens mostly/intendedly for rebounds but theoretically should apply to all
        # situations where no one has PLAYER CONTROL but the shot clock is only really
        # reset once it is established
        if event.duration >= game_state.box_score.shot_clock && game_state.ball_handler_id do
          %Event.Turnover{
            actor_id: game_state.ball_handler_id,
            team: game_state.possession,
            type: :clock_violation,
            duration: game_state.box_score.shot_clock
          }
        else
          event
        end
      end

    {game_state, event_happening}
  end

  def finished?(game_state) do
    game_state.box_score.quarter >= BoxScore.final_quarter() &&
      !BoxScore.tie?(game_state.box_score)
  end

  defp apply_event({game_state, event}) do
    {Event.apply(game_state, event), event}
  end

  # off the court actions are substitutions, tactic changes etc
  # can only be done after specific events
  defp trigger_off_the_court_actions({game_stae, %Event.Shot{success: true}}) do
    # probably only the deam with possession right?
    trigger_tactics(game_stae)
  end

  defp trigger_off_the_court_actions({game_state, %Event.Turnover{}}) do
    trigger_tactics(game_state)
  end

  defp trigger_off_the_court_actions({game_state, event = %Event.Foul{}}) do
    if BoxScore.fouled_out?(game_state.box_score, event.team, event.actor_id) do
      game_state
      |> force_substitution(event.team, event.actor_id)
      |> trigger_tactics
    else
      trigger_tactics(game_state)
    end
  end

  defp trigger_off_the_court_actions({game_state, %Event.DeflectedOutOfBounds{}}) do
    trigger_tactics(game_state)
  end

  defp trigger_off_the_court_actions({game_state, %Event.EndOfQuarter{}}) do
    trigger_tactics(game_state)
  end

  defp trigger_off_the_court_actions({game_state, _can_t_do_off_the_court}) do
    game_state
  end

  defp trigger_tactics(game_state) do
    # TODO: implement me when implementing tactics :)
    game_state
  end

  defp force_substitution(game_state, team, player_id) do
    Substitution.force_substitute(game_state, team, player_id)
  end
end
