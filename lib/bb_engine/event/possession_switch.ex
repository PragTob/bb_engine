defmodule BBEngine.Event.PossessionSwitch do
  alias BBEngine.Player
  alias BBEngine.Possession

  defstruct [
    :to_team,
    :to_player,
    :duration
  ]

  @type t :: %__MODULE__{
          to_team: Possession.t(),
          to_player: Player.id(),
          duration: non_neg_integer
        }
end
