defmodule BBEngine.Squad do
  alias BBEngine.Player

  defstruct [
    :lineup,
    :bench,
    :players
  ]

  @type t :: %__MODULE__{
          lineup: [Player.id()],
          bench: [Player.id()],
          players: [Player.t()]
        }
end
