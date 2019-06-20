defmodule BBEngine.Squad do
  alias BBEngine.Player

  defstruct [
    :lineup,
    :bench,
    # fouled out, injured etc.
    :players,
    ineligible: []
  ]

  @type lineup :: [Player.id(), ...]

  @type t :: %__MODULE__{
          lineup: lineup,
          bench: [Player.id(), ...],
          players: [Player.t(), ...],
          ineligible: [Player.id()]
        }
end
