defmodule ExCO2Mini.Collector do
  require Logger
  use GenServer

  alias ExCO2Mini.Reader

  defmodule State do
    @enforce_keys [:reader]
    defstruct(
      reader: nil,
      data: %{}
    )
  end

  def start_link(reader) when is_pid(reader) do
    GenServer.start_link(__MODULE__, reader)
  end

  def start_link(reader) when is_atom(reader) do
    Process.whereis(reader)
    |> start_link()
  end

  defp query(pid, key, fun \\ & &1) do
    case GenServer.call(pid, {:query, key}) do
      {:ok, value} -> fun.(value)
      :error -> nil
    end
  end

  def co2_ppm(pid) do
    query(pid, 0x50)
  end

  def temperature(pid) do
    query(pid, 0x42, &(&1 / 16.0 - 273.15))
  end

  # Not supported by CO2Mini:
  #
  # def relative_humidity(pid) do
  #  query(pid, 0x44, &(&1 / 100.0))
  # end

  @impl true
  def init(reader) do
    Reader.subscribe(reader, self())
    state = %State{reader: reader}
    {:ok, state}
  end

  @impl true
  def handle_call({:query, key}, _from, state) do
    {:reply, Map.fetch(state.data, key), state}
  end

  @impl true
  def handle_info({reader, {key, value}}, %State{reader: reader} = state) do
    state = %State{state | data: Map.put(state.data, key, value)}
    {:noreply, state}
  end
end
