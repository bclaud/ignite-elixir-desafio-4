defmodule Flightex.Users.Agent do
  use Agent

  alias Flightex.Users.User

  def start_link(_initial_state) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def save(%User{cpf: cpf} = user) do
    Agent.update(__MODULE__, fn state -> Map.put(state, cpf, user) end)
  end

  def get(cpf), do: Agent.get(__MODULE__, fn state -> handle_get(state, cpf) end)

  defp handle_get(state, cpf) do
    case Map.get(state, cpf) do
      nil -> {:error, "User not found"}
      user -> {:ok, user}
    end
  end
end
