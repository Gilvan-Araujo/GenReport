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

  def build(file_name) do
    file_name
    |> Parser.parse_file()
    |> Enum.reduce(empty_report(), fn line, report -> sum_hours(line, report) end)
  end

  def build() do
    {:error, "Insira o nome de um arquivo"}
  end

  defp sum_hours([name, hours, _day, _month, _year], %{"all_hours" => all_hours} = report) do
    all_hours = Map.put(all_hours, name, all_hours[name] + hours)

    %{report | "all_hours" => all_hours}
  end

  defp empty_report do
    all_hours = Enum.into(@workers, %{}, &{&1, 0})

    %{"all_hours" => all_hours}
  end
end
