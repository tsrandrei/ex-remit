defmodule Remit.Utils do
  @timezone "Europe/Stockholm"

  def normalize_string(nil), do: nil

  def normalize_string(string) do
    string = String.trim(string)
    if string == "", do: nil, else: string
  end

  def date_time_from_iso8601!(raw_time) do
    {:ok, time, _offset} = DateTime.from_iso8601(raw_time)

    # Add precision so we can store it in an utc_datetime_usec column.
    %{time | microsecond: {0, 6}}
  end

  def format_datetime(datetime) do
    # Reference: https://hexdocs.pm/timex/Timex.Format.DateTime.Formatters.Default.html
    datetime
    |> Timex.Timezone.convert(@timezone)
    |> Timex.format!("{WDshort} {D} {Mshort} at {h24}:{m}")
  end
end
