defmodule BBEngine.Event.Pass do
  alias BBEngine.Player
  alias BBEngine.Possession

  defstruct [
    :actor_id,
    :receiver_id,
    :duration,
    :team
  ]

  @type t :: %__MODULE__{
          actor_id: Player.id(),
          receiver_id: Player.id(),
          duration: non_neg_integer,
          team: Possession.t()
        }
end

defmodule BBEngine.Action.Pass do
  alias BBEngine.GameState
  alias BBEngine.Random
  alias BBEngine.Event

  @behaviour BBEngine.Action

  @impl true
  @spec play(GameState.t()) :: {GameState.t(), Event.Pass.t()}
  def play(game_state) do
    game_state
    |> simulate_action()
    |> update_game_state()
  end

  defp simulate_action(game_state) do
    {game_state, receiver_id} = choose_receiver(game_state)
    {game_state, duration} = duration(game_state)

    event = %Event.Pass{
      actor_id: game_state.ball_handler_id,
      receiver_id: receiver_id,
      duration: duration,
      team: game_state.possession
    }

    {game_state, event}
  end

  @pass_max_duration 5
  defp duration(game_state) do
    Random.uniform(game_state, @pass_max_duration)
  end

  defp choose_receiver(game_state) do
    # take into account offensive focus as well as offensive skills and defensive pressure
    Random.list_element(game_state, GameState.offense_lineup(game_state))
  end

  defp update_game_state({game_state, event}) do
    {
      %GameState{
        game_state
        | ball_handler_id: event.receiver_id
      },
      event
    }
  end
end
