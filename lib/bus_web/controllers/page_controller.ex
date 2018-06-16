defmodule ODSResponse do
  def filter(json) do
    %{:schedule => Enum.map(json["records"], fn %{"fields" => fields} -> 
      {:ok, date, utc} = DateTime.from_iso8601(fields["depart"])
      {date, fields["idligne"]}
    end)}
  end
end

defmodule ODSRequest do 
  def build(lines, stop) do
    chunkQuery = Enum.map(lines, fn {line, sens} -> "(nomcourtligne=\"#{line}\" AND sens=\"#{sens}\")" end) |> Enum.join(" OR ")
    q = "(#{chunkQuery}) AND nomarret=\"#{stop}\""
    rows = 10
    timezone = "Europe/Paris"
    sort = "-depart"

    URI.encode_query %{"q" => q, "timezone" => timezone, "rows" => rows, "sort" => sort}

  end
end

defmodule Pair do
  def make(s) do 
    case (s) do 
        [line, sens | rest] -> [{line, sens} | make(rest)]
        [] -> []
    end
  end
end



defmodule BusWeb.PageController do
  use BusWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def schedule(conn, %{"stop" => stop, "line" => line} = params) do

    lines = String.split(line, ",") |> Pair.make
  
    url = "/api/records/1.0/search/?dataset=tco-bus-circulation-passages-tr&#{ODSRequest.build(lines, stop)}"
    case HTTPoison.get("http://data.explore.star.fr" <> url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            render conn, "schedule.html", Map.merge((Poison.decode!(body) |> ODSResponse.filter), %{:title => stop})
        {:ok, %HTTPoison.Response{status_code: 404}} ->
            send_resp(conn, 500, "data.explore.star is unavailable")
        {:error, %HTTPoison.Error{reason: reason}} ->
            IO.inspect reason
    end
  end

  def schedule(conn, _params) do
    render conn, "index.html"
  end

end

