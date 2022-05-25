defmodule Flightex.Reports do
  alias Flightex.Bookings.Agent, as: BookingAgent

  def gen_between_dates(from_date, to_date) do
    BookingAgent.get_all()
    |> Stream.filter(fn {_id, %{complete_date: booking_date}} = _booking ->
      between_date?(booking_date, from_date, to_date)
    end)
    |> Stream.map(&build_line/1)
    |> Stream.map(&Enum.join(&1, ","))
    |> Enum.join("\n")
    |> then(fn content -> File.write("report.csv", content) end)
  end

  defp between_date?(booking_date, from_date, to_date) do
    booking_date = NaiveDateTime.truncate(booking_date, :second)
    from_date = NaiveDateTime.truncate(from_date, :second)
    to_date = NaiveDateTime.truncate(to_date, :second)

    start = NaiveDateTime.compare(booking_date, from_date)
    final = NaiveDateTime.compare(booking_date, to_date)

    case {start, final} do
      {:gt, :lt} -> true
      {:eq, :lt} -> true
      {:gt, :eq} -> true
      {:eq, :eq} -> false
      {:lt, :gt} -> false
      _any -> false
    end
  end

  defp build_line(
         {_id,
          %{
            user_id: user_id,
            local_origin: origin,
            local_destination: destination,
            complete_date: date
          }}
       ),
       do: [user_id, origin, destination, date]
end
