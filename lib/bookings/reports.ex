defmodule Flightex.Bookings.Report do
  alias Flightex.Bookings.Agent, as: BookingAgent

  def generate(filename) when is_bitstring(filename) do
    BookingAgent.get_all()
    |> Stream.map(&build_line/1)
    |> Stream.map(&Enum.join(&1, ","))
    |> Enum.join("\n")
    |> then(fn content -> File.write(filename, content) end)
    |> handle_result()
  end

  def generate(_), do: handle_result({:error, "String expected"})

  def gen_between_dates(from_date, to_date)
      when is_bitstring(from_date) and is_bitstring(to_date) do
    from_date = NaiveDateTime.from_iso8601(from_date)
    to_date = NaiveDateTime.from_iso8601(to_date)

    case {from_date, to_date} do
      {{:ok, naive_from}, {:ok, naive_to}} -> do_gen_between_date(naive_from, naive_to)
      _error -> handle_result({:error, "String with iso8601 format expected"})
    end
  end

  def gen_between_dates(_, _), do: handle_result({:error, "String with iso8601 format expected"})

  defp do_gen_between_date(from_date, to_date) do
    BookingAgent.get_all()
    |> Stream.filter(fn {_id, %{complete_date: booking_date}} = _booking ->
      between_date?(booking_date, from_date, to_date)
    end)
    |> Stream.map(&build_line/1)
    |> Stream.map(&Enum.join(&1, ","))
    |> Enum.join("\n")
    |> then(fn content -> File.write("report.csv", content) end)
    |> handle_result()
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

  defp handle_result(:ok), do: {:ok, "Report generated successfully"}
  defp handle_result({:error, _reason} = error), do: error
end
