defmodule BBEngine.Event.Turnover do
  alias BBEngine.Player
  alias BBEngine.Possession

  defstruct [
    :actor_id,
    :team,
    :type,
    duration: 0
  ]

  @type t :: %__MODULE__{
          actor_id: Player.id(),
          team: Possession.t(),
          type: :clock_violation,
          duration: non_neg_integer
        }
end
