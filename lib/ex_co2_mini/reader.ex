defmodule ExCO2Mini.Reader do
  require Logger
  use GenServer

  alias ExCO2Mini.Decoder

  @moduledoc """
  Reads data packets from the USB CO₂ sensor, decodes them, and sends events
  to the subscribed process(es).

  Due to the `ioctl` calls required, this module will open a `Port` to a tiny
  C wrapper, rather than reading the device directly.
  """

  defmodule State do
    @moduledoc false
    @enforce_keys [:port, :log_name]
    defstruct(
      port: nil,
      log_name: nil,
      subscribers: MapSet.new(),
      send_from: nil
    )
  end

  @doc """
  Starts reading from the USB CO₂ sensor device.

  `opts` is a keyword list.  It accepts all of the options that `GenServer.start_link/3` does, as well as the following:

  * `opts[:device]` **(required)** — The path to the CO₂Mini device, e.g. `/dev/hidraw0` or a symlink to the device.
  * `opts[:subscribers]` — A list of initial subscribers (default: none).  
    * This can be used to save a call to `subscribe/2`, and/or to ensure correct data routing in the case of a supervisor restart.
  * `opts[:send_from_name]` — If true, then `opts[:name]` must be included as well.  Messages sent by this reader will use that name instead of the PID.

  Returns `{:ok, pid}` once the reader (and wrapper process) has been successfully started.
  """

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

  @doc """
  Starts sending data values to a target process.

  `target` can be a PID or a registered name (atom or module).

  A given name or PID can only be subscribed once.  Subsequent calls to this
  function will be effectively ignored, and `target` will still only receive
  one message per data packet.  However, if a process may receive multiple
  messages per packet if subscribed under both its PID and name.
  """

  def subscribe(reader, target \\ self()) do
    GenServer.call(reader, {:subscribe, target})
  end

  @impl true
  def init({device, subscribers, send_from, log_name}) do
    Process.flag(:trap_exit, true)
    port = open_port(device)

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

  @impl true
  def handle_info({:EXIT, port, reason}, %State{port: port} = state) do
    err = "#{state.log_name} port has died: #{inspect(reason)}"
    Logger.error(err)
    {:stop, err, state}
  end

  # Used for testing.
  defp open_port(:dummy = dev), do: dev

  defp open_port(device) do
    args = decoder_key() ++ [device]
    Port.open({:spawn_executable, reader_executable()}, [:binary, {:args, args}])
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
