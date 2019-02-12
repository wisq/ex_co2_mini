defmodule ExCO2Mini.CollectorTest do
  use ExUnit.Case
  doctest ExCO2Mini.Collector
  alias ExCO2Mini.Collector

  defmodule MockReader do
    use GenServer

    def start_link(parent) do
      GenServer.start_link(__MODULE__, parent)
    end

    @impl true
    def init(parent) do
      {:ok, parent}
    end

    @impl true
    def handle_call(data, _from, parent) do
      send(parent, {:call, data})
      {:reply, :ok, parent}
    end
  end

  test "subscribes on startup" do
    {:ok, reader} = start_supervised({MockReader, self()})
    {:ok, collector} = start_supervised({Collector, reader: reader})

    assert_received {:call, {:subscribe, ^collector}}

    :ok = stop_supervised(Collector)
    :ok = stop_supervised(MockReader)
  end

  test "subscribes with name" do
    name = __MODULE__.NamedCollector
    {:ok, reader} = start_supervised({MockReader, self()})

    {:ok, _} =
      start_supervised(
        {Collector,
         [
           name: name,
           subscribe_as_name: true,
           reader: reader
         ]}
      )

    assert_received {:call, {:subscribe, ^name}}
  end

  test "returns nil data at start" do
    {:ok, reader} = start_supervised({MockReader, self()})
    {:ok, collector} = start_supervised({Collector, reader: reader})

    assert Collector.temperature(collector) == nil
    assert Collector.co2_ppm(collector) == nil
  end

  test "data is nil at start" do
    {:ok, reader} = start_supervised({MockReader, self()})
    {:ok, collector} = start_supervised({Collector, reader: reader})

    assert Collector.temperature(collector) == nil
    assert Collector.co2_ppm(collector) == nil
  end

  test "collects temperature data" do
    {:ok, reader} = start_supervised({MockReader, self()})
    {:ok, collector} = start_supervised({Collector, reader: reader})

    send(collector, {reader, {66, 4729}})
    assert_in_delta(Collector.temperature(collector), 22.4125, 0.0001)
  end

  test "collects CO2 data" do
    {:ok, reader} = start_supervised({MockReader, self()})
    {:ok, collector} = start_supervised({Collector, reader: reader})

    send(collector, {reader, {80, 699}})
    assert Collector.co2_ppm(collector) == 699
  end

  test "ignores extraneous data" do
    {:ok, reader} = start_supervised({MockReader, self()})
    {:ok, collector} = start_supervised({Collector, reader: reader})

    [
      {109, 1806},
      {110, 26087},
      {113, 701},
      {65, 0},
      {66, 5000},
      {67, 3066},
      {79, 7130},
      {80, 801},
      {82, 10009},
      {86, 10020},
      {87, 8211}
    ]
    |> Enum.each(fn data -> send(collector, {reader, data}) end)

    assert_in_delta(Collector.temperature(collector), 39.35, 0.0001)
    assert Collector.co2_ppm(collector) == 801
  end
end
