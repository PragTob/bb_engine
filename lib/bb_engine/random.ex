defmodule BBEngine.Random do
  alias BBEngine.GameState

  def successful?(game_state, value, opposing_value) do
    sum = value + opposing_value

    seed = game_state.current_seed
    {random, new_seed} = :rand.uniform_s(sum, seed)
    new_game_state = %GameState{ game_state | current_seed: new_seed}

    {random <= value, new_game_state}
  end
end
