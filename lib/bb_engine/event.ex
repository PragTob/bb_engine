defmodule BBEngine.Event do
  alias BBEngine.Event
  alias BBEngine.Event.Rebound
  alias BBEngine.Event.Shot
  alias BBEngine.Event.PossessionSwitch


  @type t :: Rebound.t | Shot.t | PossessionSwitch.t
end
