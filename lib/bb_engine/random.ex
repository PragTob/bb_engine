defmodule BBEngine.Random do
  def successful?(value, opposing_value) do
    sum = value + opposing_value
    :rand.uniform(sum) <= value
  end
end
