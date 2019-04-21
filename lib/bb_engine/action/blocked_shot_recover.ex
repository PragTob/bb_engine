defmodule BBEngine.Action.BlockedShotRecover do
  alias BBEngine.GameState
  alias BBEngine.Event
  alias BBEngine.Random

  @doc """
  The ball is loose after a blocked shot - what will happen?
  """

  @behaviour BBEngine.Action

  @impl true
  @spec play(GameState.t()) ::
          {GameState.t(), Event.DeflectedOutOfBounds.t() | Event.BlockedShotRecovery.t()}
  def play(game_state) do
    on_court_players =
      GameState.current_players(game_state, :home) ++ GameState.current_players(game_state, :road)

    # calculate better/more intriciately who is likely to get the ball
    probabilities =
      on_court_players
      # naturally more computation in here
      |> Enum.map(fn player -> {player, 1} end)
      |> Map.new()
      |> Map.put(:out_of_bounds, 5)

    {new_game_state, result} = Random.weighted(game_state, probabilities)

    {new_game_state, resulting_event(result, game_state)}
  end

  defp resulting_event(:out_of_bounds, game_state) do
    [%Event.Block{actor_id: blocker_id} | _] = game_state.events

    %Event.DeflectedOutOfBounds{
      actor_id: blocker_id,
      # time already accounted for in the block itself
      duration: 0
    }
  end

  # Doing a proper random roll we'd need to take the game state etc
  # and it's not _that_ important
  @duration 1
  defp resulting_event(recoverer, game_state) do
    offense_team = game_state.possession

    %Event.BlockedShotRecovery{
      to_team: recoverer.team,
      actor_id: recoverer.id,
      type: recovery_type(recoverer.team, offense_team),
      duration: @duration
    }
  end

  defp recovery_type(recoverer_team, offense_team) do
    if recoverer_team == offense_team do
      :offensive
    else
      :defensive
    end
  end
end
