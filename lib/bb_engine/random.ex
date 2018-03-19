defmodule BBEngine.Random do
  @moduledoc """
  All `:rand` access should be confined to this module. This is to make sure
  that they all use the provided `current_seed` in GameState and also set it.
  """
  alias BBEngine.GameState

  def seed(seed_value \\ :rand.seed_s(:exrop)) do
    :rand.seed_s(seed_value)
  end

  def successful?(game_state, value, opposing_value) do
    sum = value + opposing_value

    {new_game_state, random} = uniform(game_state, sum)

    {new_game_state, random <= value}
  end

  def uniform(game_state = %GameState{current_seed: seed}, n) do
    {random, new_seed} = :rand.uniform_s(n, seed)
    new_game_state = %GameState{ game_state | current_seed: new_seed}
    {new_game_state, random}
  end

  def list_element(game_state, list) do
    {new_game_state, random} = uniform(game_state, length(list))
    index = random - 1
    {new_game_state, Enum.at(list, index)}
  end

  def weighted(game_state, probability_points) do
    {list, max_value} = Enum.reduce(probability_points, {[], 0}, fn {entity, value}, {list, limit} ->
      to_value = value + limit
      {[{to_value, entity} | list], to_value}
    end)
    list = Enum.reverse list
    {new_game_state, random} = uniform(game_state, max_value)
    {_, winner} = Enum.find(list, fn {value, _element} -> random <= value end)
    {new_game_state, winner}
  end
end
