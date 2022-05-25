defmodule Flightex do
  defdelegate generate_report(from_date, to_date), to: Flightex.Reports, as: :gen_between_dates
end
