defmodule BBEngine.Simulation do
  alias BBEngine.{GameState, Action, Random, Event, BoxScore, Squad}

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
  @final_quarter 4
  @spec run_simulation(GameState.t()) :: GameState.t()
  def run_simulation({:done, game_state}) do
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
  @spec advance_simulation(GameState.t()) :: GameState.t() | {:done, GameState.t()}
  def advance_simulation(game_state = %GameState{clock_seconds: clock_seconds})
      when clock_seconds <= 0 do
    # Do substitutions etc.
    if finished?(game_state) do
      {:done, game_state}
    else
      # Put into event
      new_quarter = game_state.quarter + 1

      %GameState{
        game_state
        | quarter: new_quarter,
          clock_seconds: quarter_seconds(new_quarter),
          shot_clock: GameState.shot_clock_seconds()
      }
    end
  end

  def advance_simulation(game_state) do
    # we could check for an expired shot clock here and only determine actions etc.
    # if the shot clock isn't expired but that'd double the check with after the action
    # was taken for probably not too many winnings.
    game_state
    |> determine_next_action
    |> play_action
    |> catch_time_violations
    |> apply_event
  end

  defp finished?(game_state) do
    game_state.quarter >= @final_quarter && !BoxScore.tie?(game_state.box_score)
  end

  @seconds_per_quarter GameState.seconds_per_quarter()
  @seconds_per_overtime 5 * 60
  defp quarter_seconds(quarter) when quarter <= @final_quarter, do: @seconds_per_quarter
  defp quarter_seconds(_quarter), do: @seconds_per_overtime

  @spec determine_next_action(GameState.t()) :: {GameState.t(), module}
  defp determine_next_action(game_state = %GameState{events: []}) do
    # should be jump ball
    {game_state, Action.Pass}
  end

  defp determine_next_action(game_state = %GameState{events: [last_event | _]}) do
    reaction = reaction_action(last_event)

    if reaction do
      {game_state, reaction}
    else
      determine_action(game_state)
    end
  end

  defp reaction_action(%Event.Shot{success: false}), do: Action.Rebound
  defp reaction_action(%Event.Shot{success: true}), do: Action.ThrowIn
  defp reaction_action(%Event.Turnover{}), do: Action.ThrowIn
  defp reaction_action(%Event.Block{}), do: Action.BlockedShotRecover
  defp reaction_action(%Event.DeflectedOutOfBounds{}), do: Action.ThrowIn
  defp reaction_action(%Event.TimeRanOut{}), do: Action.ThrowIn
  defp reaction_action(_), do: nil

  @time_critical 8
  defp determine_action(gs = %GameState{clock_seconds: clock_seconds, shot_clock: shot_clock})
       when clock_seconds <= @time_critical or shot_clock <= @time_critical do
    {gs, Action.Forced}
  end

  @action_probability_map %{
    Action.Pass => 75,
    Action.TwoPointShot => 17,
    Action.ThreePointShot => 8
  }
  defp determine_action(game_state) do
    # Obviously needs to get more sophisticated/adaptive to team tactics
    Random.weighted(game_state, @action_probability_map)
  end

  @spec play_action({GameState.t(), module}) :: {GameState.t(), Event.t()}
  defp play_action({game_state, action_module}) do
    action_module.play(game_state)
  end

  defp catch_time_violations({game_state, event}) do
    event =
      if event.duration > game_state.clock_seconds do
        %Event.TimeRanOut{
          duration: game_state.clock_seconds
        }
      else
        if event.duration > game_state.shot_clock && event.__struct__ != Event.Rebound do
          # We need to somehow take care that this doesn't happen with
          # steals/blocks because then it should be a TO _before_ the
          # steal/block happens
          # also the event could get some information on context, like
          # someone didn't get the shot off in time or whatever
          %Event.Turnover{
            actor_id: game_state.ball_handler_id,
            team: game_state.possession,
            type: :clock_violation,
            duration: game_state.shot_clock
          }
        else
          event
        end
      end

    {game_state, event}
  end

  defp apply_event({game_state, event}) do
    Event.apply(game_state, event)
  end
end
