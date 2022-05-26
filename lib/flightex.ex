defmodule Flightex do
  # coveralls-ignore-start
  def start_agents() do
    Flightex.Bookings.Agent.start_link(%{})
    Flightex.Users.Agent.start_link(%{})
  end

  defdelegate generate_report(from_date, to_date),
    to: Flightex.Bookings.Report,
    as: :gen_between_dates

  defdelegate create_or_update_booking(params), to: Flightex.Bookings.CreateOrUpdate, as: :call

  # coveralls-ignore-stop
end
