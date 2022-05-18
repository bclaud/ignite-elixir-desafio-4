defmodule Flightex.Bookings.Agent do
  use Agent

  alias Flightex.Bookings.Booking

  def start_link(_initial_state) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def save(%Booking{id: id} = booking) do
    Agent.update(__MODULE__, fn state -> Map.put(state, id, booking) end)
    {:ok, id}
  end

  def get(id) do
    Agent.get(__MODULE__, fn state -> handle_get(state, id) end)
  end

  defp handle_get(state, id) do
    case Map.get(state, id) do
      nil -> {:error, "Booking not found"}
      booking -> {:ok, booking}
    end
  end
end
