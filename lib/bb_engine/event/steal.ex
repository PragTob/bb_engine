defmodule BBEngine.Event.Steal do
  alias BBEngine.Player
  alias BBEngine.Possession

  @moduledoc """
  These are turnovers committed by individuals by themselves.

  For instance this doesn't count steals as that's a separate event and needs more fields.
  These turnovers are intended to be shot clock violations, stepping out of bounds,
  traveling etc.
  """

  defstruct [
    :actor_id,
    :stolen_from,
    :team,
    :duration
  ]

  @type t :: %__MODULE__{
          actor_id: Player.id(),
          stolen_from: Player.id(),
          team: Possession.t(),
          duration: non_neg_integer
        }
end
