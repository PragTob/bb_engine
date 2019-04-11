defmodule BBEngine.Event.Shot do
  alias BBEngine.Player
  alias BBEngine.Possession

  defstruct [
    :actor_id,
    :defender_id,
    :team,
    :type,
    :points,
    :success,
    :duration
  ]

  @type t :: %__MODULE__{
          actor_id: Player.id(),
          defender_id: Player.id(),
          team: Possession.t(),
          type: :midrange | :threepoint,
          points: 1..3,
          success: boolean,
          duration: non_neg_integer
        }

  @behaviour BBEngine.Event
  @impl true
  def apply(game_state, _event) do
    # noop as the real changes happen in statistics/reactions for now
    # will change when/if we get statistics over
    game_state
  end
end
