# Este teste é opcional, mas vale a pena tentar e se desafiar 😉

defmodule Flightex.Bookings.ReportTest do
  use ExUnit.Case, async: true

  alias Flightex.Bookings.Report

  describe "generate/1" do
    setup do
      Flightex.start_agents()

      :ok
    end

    test "when called, return the content" do
      params = %{
        complete_date: ~N[2001-05-07 12:00:00],
        local_origin: "Brasilia",
        local_destination: "Bananeiras",
        user_id: "12345678900",
        id: UUID.uuid4()
      }

      content = "12345678900,Brasilia,Bananeiras,2001-05-07 12:00:00"

      Flightex.create_or_update_booking(params)
      Report.generate("report-test.csv")
      {:ok, file} = File.read("report-test.csv")

      assert file =~ content

      # teardown
      File.rm!("report-test.csv")
    end

    test "returns tuple with error" do
      assert {:error, _reason} = Report.generate(0)
    end
  end

  describe "gen_between_dates/2" do
    setup %{} do
      Flightex.start_agents()

      :ok
    end

    test "when called, return the filtered content" do
      params = %{
        complete_date: ~N[2001-05-07 12:00:00],
        local_origin: "Brasilia",
        local_destination: "Bananeiras",
        user_id: "12345678900",
        id: UUID.uuid4()
      }

      params2 = %{
        complete_date: ~N[1990-05-07 12:00:00],
        local_origin: "Brasilia",
        local_destination: "Bananeiras",
        user_id: "12345678900",
        id: UUID.uuid4()
      }

      params3 = %{
        complete_date: ~N[2000-01-01 01:01:01],
        local_origin: "Brasilia",
        local_destination: "Bananeiras",
        user_id: "12345678900",
        id: UUID.uuid4()
      }

      params4 = %{
        complete_date: ~N[2022-01-01 01:01:01],
        local_origin: "Brasilia",
        local_destination: "Bananeiras",
        user_id: "12345678900",
        id: UUID.uuid4()
      }

      content = "12345678900,Brasilia,Bananeiras,2001-05-07 12:00:00"

      Flightex.create_or_update_booking(params)
      Flightex.create_or_update_booking(params2)
      Flightex.create_or_update_booking(params3)
      Flightex.create_or_update_booking(params4)
      Report.gen_between_dates("2000-01-01T01:01:01Z", "2022-01-01T01:01:01Z")
      {:ok, file} = File.read("report.csv")

      assert file =~ content

      # teardown
      File.rm!("report.csv")
    end

    test "Return error when invalid args are provided" do
      {:error, _reason} = Report.gen_between_dates(0, 0)
    end

    test "Return error when invalid string format is provided" do
      {:error, _reason} = Report.gen_between_dates("20000101T01:01:01Z", "20220101T01:01:01Z")
    end
  end
end
