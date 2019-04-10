defmodule BBEngine.Possession do
  @type t :: :home | :opposite
  @doc """
      iex> BBEngine.Possession.opposite(:home)
      :road
      iex> BBEngine.Possession.opposite(:road)
      :home
  """
  def opposite(:home), do: :road
  def opposite(:road), do: :home
end
