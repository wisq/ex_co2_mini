defmodule ExCO2Mini.Collector do
  require Logger
  use GenServer

  alias ExCO2Mini.Reader

  @moduledoc """
  Collects data packets from a `ExCO2Mini.Reader` instance and provides simple on-demand access to CO₂ and temperature data.
  """

  defmodule State do
    @moduledoc false
    @enforce_keys [:reader, :log_name]
    defstruct(
      reader: nil,
      log_name: nil,
      data: %{}
    )
  end

  @doc """
  Creates a process to collect data.

  `opts` is a keyword list.  It accepts all of the options that `GenServer.start_link/3` does, as well as the following:

  * `opts[:reader]` **(required)** — The PID or name (atom) of a `ExCO2Meter.Reader` process.
    * The collector will automatically call `ExCO2Mini.Reader.subscribe/2`.
  * `opts[:subscribe_as_name]` — If true, then `opts[:name]` must be included as well.  The collector will subscribe using its name rather than PID.
    * This can be useful in preventing the `ExCO2Mini.Reader` process from accumulating defunct subscriptions if this collector is restarted repeatedly.

  Returns `{:ok, pid}` once the collector has been successfully started and has subscribed to the reader.
  """

  def start_link(opts) do
    reader = Keyword.fetch!(opts, :reader)
    subscribe_as = if Keyword.get(opts, :subscribe_as_name), do: Keyword.fetch!(opts, :name)

    log_name =
      Keyword.get(opts, :name, __MODULE__)
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    GenServer.start_link(__MODULE__, {reader, subscribe_as, log_name}, opts)
  end

  defp query(pid, key, fun \\ & &1) do
    case GenServer.call(pid, {:query, key}) do
      {:ok, value} -> fun.(value)
      :error -> nil
    end
  end

  @doc "Returns the CO₂ concentration, in parts per million (ppm)."
  def co2_ppm(pid) do
    query(pid, 0x50)
  end

  @doc "Returns the ambient temperature, in degrees centigrade (°C)."
  def temperature(pid) do
    query(pid, 0x42, &(&1 / 16.0 - 273.15))
  end

  # Not supported by CO₂Mini:
  #
  # def relative_humidity(pid) do
  #  query(pid, 0x44, &(&1 / 100.0))
  # end

  @impl true
  def init({reader, subscribe_as, log_name}) do
    Reader.subscribe(reader, subscribe_as || self())

    state = %State{
      reader: reader,
      log_name: log_name
    }

    Logger.info("#{state.log_name} started.")
    {:ok, state}
  end

  @impl true
  def handle_call({:query, key}, _from, state) do
    {:reply, Map.fetch(state.data, key), state}
  end

  @impl true
  def handle_info({reader, {key, value} = data}, %State{reader: reader} = state) do
    state = %State{state | data: Map.put(state.data, key, value)}
    Logger.debug("#{state.log_name} received #{inspect(data)} from #{inspect(reader)}.")
    {:noreply, state}
  end
end
