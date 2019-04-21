defmodule BBEngine.GameViewer do
  alias BBEngine.{GameState, Random, Event, Squad, Simulation}

  @spec simulate(Squad.t(), Squad.t(), Random.state()) :: GameState.t()
  def simulate(home_squad, road_squad, seed \\ Random.seed()) do
    home_squad
    |> Simulation.new(road_squad, seed)
    |> proceed_simulation
  end

  defp proceed_simulation({:done, game_state}) do
    game_state
  end

  defp proceed_simulation(game_state) do
    game_state
    |> Simulation.simulate_event()
    |> log_event
    |> proceed_simulation
  end

  defp log_event(game_state = %{events: [current_event | _]}) do
    game_state
    |> log_it(current_event)
    |> IO.puts()

    game_state
  end

  defp log_event({:done, game_state}) do
    IO.puts("game is over apparently")
    {:done, game_state}
  end

  defp log_it(game_state, event) do
    "#{game_clock(game_state)} - #{event_log(event)} #{score(game_state)}"
  end

  @spec event_log(Event.t()) :: String.t()
  defp event_log(event = %Event.Pass{}) do
    "#{event.actor_id} passes to #{event.receiver_id}"
  end

  defp event_log(event = %Event.Rebound{}) do
    "#{event.actor_id} grabs the #{event.type} rebound for #{event.team}"
  end

  defp event_log(event = %Event.Shot{success: true}) do
    "#{event.actor_id} makes the #{event.type} shot against #{event.defender_id}"
  end

  defp event_log(event = %Event.Shot{success: false}) do
    "#{event.actor_id} fails to make the #{event.type} shot against #{event.defender_id}"
  end

  defp event_log(event = %Event.PossessionSwitch{}) do
    "And the possession switches to #{event.to_player} from #{event.to_team}"
  end

  defp event_log(event = %Event.Turnover{type: :clock_violation}) do
    "And #{event.actor_id} took too long and we have a clock violation!"
  end

  defp event_log(event = %Event.Turnover{type: :out_of_bound_pass}) do
    "And #{event.actor_id} throws the ball out of bounds!"
  end

  defp event_log(event = %Event.Steal{}) do
    "And #{event.actor_id} steals the ball from #{event.stolen_from}!"
  end

  defp event_log(event = %Event.Block{}) do
    "And #{event.actor_id} blocks the shot from #{event.blocked_player_id}!"
  end

  defp event_log(event = %Event.BlockedShotRecovery{type: :offensive}) do
    "And #{event.actor_id} manages to snatch up the blocked shot, the offense maintains control!"
  end

  defp event_log(event = %Event.BlockedShotRecovery{type: :defensive}) do
    "And #{event.actor_id} grabs a hold of the blocked shot, we go the other way."
  end

  defp event_log(event = %Event.DeflectedOutOfBounds{}) do
    "The ball was deflected out of bounds by #{event.actor_id} - the offense keeps possession and we go to an inbounds play."
  end

  defp game_clock(game_state) do
    "#{game_state.quarter} quarter #{format_clock(game_state.clock_seconds)}"
  end

  @seconds_per_minute 60
  defp format_clock(seconds) do
    seconds = rem(seconds, @seconds_per_minute)
    "#{div(seconds, @seconds_per_minute)}:#{seconds_padding(seconds)}#{seconds}"
  end

  defp seconds_padding(seconds) when seconds <= 9, do: "0"
  defp seconds_padding(_), do: ""

  defp score(game_state) do
    "(#{game_state.box_score.home.team.points}-#{game_state.box_score.road.team.points})"
  end
end
