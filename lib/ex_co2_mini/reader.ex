defmodule ExCO2Mini.Reader do
  require Logger
  use GenServer

  alias ExCO2Mini.Decoder

  defmodule State do
    @enforce_keys [:port, :log_name]
    defstruct(
      port: nil,
      log_name: nil,
      subscribers: MapSet.new(),
      send_from: nil
    )
  end

  def start_link(opts) do
    device = Keyword.fetch!(opts, :device)
    subscribers = Keyword.get(opts, :subscribers, [])
    send_from = if Keyword.get(opts, :send_from_name), do: Keyword.fetch!(opts, :name)

    log_name =
      Keyword.get(opts, :name, __MODULE__)
      |> Atom.to_string()
      |> String.replace("Elixir.", "")

    GenServer.start_link(__MODULE__, {device, subscribers, send_from, log_name}, opts)
  end

  def subscribe(reader, target \\ self()) do
    GenServer.call(reader, {:subscribe, target})
  end

  @impl true
  def init({device, subscribers, send_from, log_name}) do
    args = decoder_key() ++ [device]
    port = Port.open({:spawn_executable, reader_executable()}, [:binary, {:args, args}])

    state = %State{
      port: port,
      subscribers: MapSet.new(subscribers),
      send_from: send_from || self(),
      log_name: log_name
    }

    Logger.info("#{state.log_name} started.")
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
      send(pid, {state.send_from, data})
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
