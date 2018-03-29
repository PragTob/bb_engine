defmodule BBEngine.Action.Forced do
  alias BBEngine.GameState
  alias BBEngine.Random
  alias BBEngine.Event
  alias BBEngine.Action.TwoPointShot

  def play(game_state) do
    # TODO: make the malus dependent on the player... like a percent of their
    # skills but also dependent on experience - might even become a boon for
    # very special players sometimes
    # We could also pass here.. dunnoo... also on the time.
    {game_state, shot_event} = TwoPointShot.attempt(game_state, 15)
    {game_state, elapsed_time} = elapsed_time(game_state)

    {game_state, %Event.Shot{shot_event | duration: elapsed_time}}
  end

  defp elapsed_time(game_state = %GameState{shot_clock: shot_clock}) do
    Random.uniform(game_state, shot_clock)
  end
end