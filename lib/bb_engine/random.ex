defmodule BBEngine.Random do
  @moduledoc """
  All `:rand` access should be confined to this module. This is to make sure
  that they all use the provided `current_seed` in GameState and also set it.
  """
  alias BBEngine.GameState

  @type state :: :rand.state()

  def seed(seed_value \\ :rand.seed_s(:exrop)) do
    :rand.seed_s(seed_value)
  end

  @spec successful?(GameState.t(), number, number) :: {GameState.t(), boolean}
  def successful?(game_state, value, opposing_value) do
    sum = value + opposing_value

    {new_game_state, random} = uniform(game_state)

    {new_game_state, random * sum <= value}
  end

  # BEWARE: uniform returns numbers  0.0 <= n < 1.0 so no 1.0 nut 0.0
  @spec uniform(GameState.t()) :: {GameState.t(), float}
  def uniform(game_state = %GameState{current_seed: seed}) do
    {random, new_seed} = :rand.uniform_s(seed)
    new_game_state = %GameState{game_state | current_seed: new_seed}
    {new_game_state, random}
  end

  @spec uniform(GameState.t(), number) :: {GameState.t(), float}
  def uniform(game_state, max_number) do
    {new_game_state, random} = uniform(game_state)
    {new_game_state, random * max_number}
  end

  # BEWARE: uniform returns numbers 1..n so no 0
  @spec uniform_int(GameState.t(), integer) :: {GameState.t(), integer}
  def uniform_int(game_state = %GameState{current_seed: seed}, n) do
    {random, new_seed} = :rand.uniform_s(n, seed)
    new_game_state = %GameState{game_state | current_seed: new_seed}
    {new_game_state, random}
  end

  @spec list_element(GameState.t(), [any]) :: {GameState.t(), any}
  def list_element(game_state, list) do
    {new_game_state, random} = uniform_int(game_state, length(list))
    index = random - 1
    {new_game_state, Enum.at(list, index)}
  end

  @type option :: any
  # negative numbers mess this up, safe guard against it
  @type probability :: number
  @type weighted_map :: %{option => probability}
  @spec weighted(GameState.t(), weighted_map) :: {GameState.t(), any}
  def weighted(game_state, probability_map) do
    {list, max_value} =
      Enum.reduce(probability_map, {[], 0}, fn {entity, value}, {list, limit} ->
        to_value = value + limit
        {[{to_value, entity} | list], to_value}
      end)

    list = Enum.reverse(list)
    {new_game_state, random} = uniform(game_state, max_value)
    {_, winner} = Enum.find(list, fn {value, _element} -> random <= value end)
    {new_game_state, winner}
  end
end
