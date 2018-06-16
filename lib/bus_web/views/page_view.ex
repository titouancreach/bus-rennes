defmodule BusWeb.PageView do
  use BusWeb, :view


  def removeLeading(s) do
    case (s) do 
      "0" <> rest -> removeLeading rest
      s -> s
    end
  end

  def getCssListClass(index) do
    case rem(index, 2) do
      0 -> "is-pair"
      _ -> ""
    end
  end


  def line(key) do 
    {_, line} = key;
    removeLeading line
  end

  def remainingTime(key) do
    {datetime, idligne} = key
    now = DateTime.utc_now()
    totalSecond = DateTime.diff(datetime, now)

    h = div(totalSecond, 3600)
    m = div(rem(totalSecond, 3600), 60)
    s = rem(totalSecond, 60)

    case {h, m, s} do 
      {0, 0, s} -> "Fiew seconds"
      {0, m, _} -> "#{m}m"
      {h, m, _} -> "#{h}h #{m}m"
    end

  end
end
