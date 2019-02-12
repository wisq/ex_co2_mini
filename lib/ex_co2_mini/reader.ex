defmodule ExCO2Mini.Reader do
  require Logger
  use GenServer

  alias ExCO2Mini.Decoder

  defmodule State do
    @enforce_keys [:port]
    defstruct(
      port: nil,
      subscribers: MapSet.new()
    )
  end

  def start_link(device) do
    GenServer.start_link(__MODULE__, device)
  end

  def subscribe(reader, target \\ self()) do
    GenServer.call(reader, {:subscribe, target})
  end

  @impl true
  def init(device) do
    args = decoder_key() ++ [device]
    port = Port.open({:spawn_executable, reader_executable()}, [:binary, {:args, args}])

    state = %State{port: port}

    {:ok, state}
  end

  @impl true
  def handle_call({:subscribe, pid}, _from, state) do
    state = %State{state | subscribers: MapSet.put(state.subscribers, pid)}
    {:reply, :ok, state}
  end

  @impl true
  def handle_info({port, {:data, bytes}}, %State{port: port} = state) do
    {_key, _value} = data = Decoder.decode(bytes)

    Enum.each(state.subscribers, fn pid ->
      send(pid, {self(), data})
    end)

    {:noreply, state}
  end

  defp reader_executable do
    :code.priv_dir(:ex_co2_mini)
    |> Path.join("reader")
  end

  defp decoder_key do
    Decoder.key()
    |> Enum.map(&Integer.to_string/1)
  end
end
