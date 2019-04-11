defmodule BBEngine.Event.Rebound do
  alias BBEngine.Player
  alias BBEngine.Possession

  defstruct [
    :actor_id,
    :duration,
    :team,
    :type
  ]

  @type t :: %__MODULE__{
          actor_id: Player.id(),
          duration: non_neg_integer,
          team: Possession.t(),
          type: :offensive | :defensive
        }
end
