defmodule GenReport do
  alias GenReport.Parser

  @workers [
    "daniele",
    "mayk",
    "giuliano",
    "cleiton",
    "jakeliny",
    "joseph",
    "diego",
    "danilo",
    "rafael",
    "vinicius"
  ]

  @months [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  @years [
    2016,
    2017,
    2018,
    2019,
    2020
  ]

  def build(file_name) do
    # execution time: 210141ms
    file_name
    |> Parser.parse_file()
    |> Enum.reduce(empty_report(), fn line, report -> sum_hours(line, report) end)
  end

  def build() do
    {:error, "Insira o nome de um arquivo"}
  end

  def build_parallel(filenames) when not is_list(filenames) do
    {:error, "Please provide a filename list!"}
  end

  def build_parallel(filenames) do
    # execution time: 51985
    filenames
    |> Task.async_stream(&build/1)
    |> Enum.reduce(empty_report(), fn {:ok, result}, report -> sum_reports(report, result) end)
  end

  defp sum_hours(
         [name, hours, _day, month, year],
         %{
           "all_hours" => all_hours,
           "hours_per_month" => hours_per_month,
           "hours_per_year" => hours_per_year
         } = report
       ) do
    all_hours = Map.put(all_hours, name, all_hours[name] + hours)

    hours_per_month_per_worker =
      Map.put(hours_per_month[name], month, hours_per_month[name][month] + hours)

    hours_per_month = Map.put(hours_per_month, name, hours_per_month_per_worker)

    hours_per_year_per_worker =
      Map.put(hours_per_year[name], year, hours_per_year[name][year] + hours)

    hours_per_year = Map.put(hours_per_year, name, hours_per_year_per_worker)

    %{
      report
      | "all_hours" => all_hours,
        "hours_per_month" => hours_per_month,
        "hours_per_year" => hours_per_year
    }
  end

  defp sum_reports(
         %{
           "all_hours" => all_hours1,
           "hours_per_month" => hours_per_month1,
           "hours_per_year" => hours_per_year1
         },
         %{
           "all_hours" => all_hours2,
           "hours_per_month" => hours_per_month2,
           "hours_per_year" => hours_per_year2
         }
       ) do
    all_hours = merge_maps(all_hours1, all_hours2)
    hours_per_month = merge_maps_within_maps(hours_per_month1, hours_per_month2)
    hours_per_year = merge_maps_within_maps(hours_per_year1, hours_per_year2)

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp merge_maps_within_maps(map1, map2) do
    Map.merge(map1, map2, fn key, _value1, _value2 -> merge_maps(map1[key], map2[key]) end)
  end

  defp empty_months, do: Enum.into(@months, %{}, &{&1, 0})

  defp empty_years, do: Enum.into(@years, %{}, &{&1, 0})

  defp empty_report do
    all_hours = Enum.into(@workers, %{}, &{&1, 0})

    hours_per_month = Enum.into(@workers, %{}, &{&1, empty_months()})

    hours_per_year = Enum.into(@workers, %{}, &{&1, empty_years()})

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
