defmodule BBEngine.Action.FreeThrow do
  alias BBEngine.Random
  alias BBEngine.Event
  alias BBEngine.GameState
  alias BBEngine.Player

  @behaviour BBEngine.Action

  @free_throw_base_difficulty 50

  @type result :: Event.Shot.t() | Event.Block.t() | Event.Foul.t()
  @impl true
  @spec play(GameState.t()) :: {GameState.t(), result}
  def play(game_state) do
    shooter = GameState.ball_handler(game_state)
    # ofc use free throw skill, experience, pressure, traits etc...
    {game_state, success} =
      Random.successful?(game_state, shooter.offensive_rating, @free_throw_base_difficulty)

    [last_event | _] = game_state.events

    event = %Event.FreeThrow{
      actor_id: shooter.id,
      team: shooter.team,
      success: success,
      duration: 0,
      free_throws_remaining: remaining(last_event)
    }

    {game_state, event}
  end

  defp remaining(%Event.FreeThrow{free_throws_remaining: remaining}),
    do: remaining - 1

  # we already shot one free throw
  # TODO: 3 points etc.
  defp remaining(%Event.Foul{}), do: 1
end
