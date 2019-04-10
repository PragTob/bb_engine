defmodule BBEngine.Event do
  alias BBEngine.Event

  @type t ::
          Event.Rebound.t()
          | Event.Shot.t()
          | Event.PossessionSwitch.t()
          | Event.Pass.t()
          | Event.Turnover.t()
end
