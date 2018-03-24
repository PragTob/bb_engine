defmodule BBEngine.Events.Shot do
  defstruct [
    :actor_id,
    :defender_id,
    :team,
    :type,
    :success,
    :duration
  ]
end

defmodule BBEngine.Actions.TwoPointShot do
  alias BBEngine.Random
  alias BBEngine.Events.Shot
  alias BBEngine.GameState

  def play(game_state = %GameState{ball_handler_id: ball_handler_id}) do
    opponent_id = Map.fetch!(game_state.matchups, ball_handler_id)
    opponent = Map.fetch! game_state.players, opponent_id
    ball_handler = Map.fetch! game_state.players, ball_handler_id
    {new_game_state, elapsed_time} = elapsed_time(game_state)
    shot = %Shot{
      actor_id: ball_handler_id,
      defender_id: opponent_id,
      team: ball_handler.team,
      duration: elapsed_time
    }
    {final_game_state, success} =
      Random.successful?(new_game_state, ball_handler.offensive_rating, opponent.defensive_rating)
    {final_game_state, %Shot{shot | success: success}}
  end

  defp elapsed_time(game_state) do
    {new_game_state, random} = Random.uniform(game_state, 14)
    elapsed_time = 10 + random
    {new_game_state, elapsed_time}
  end
end
