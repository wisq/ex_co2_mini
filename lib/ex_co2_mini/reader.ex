defmodule ExCO2Mini.Reader do
  require Logger
  use GenServer

  alias ExCO2Mini.Decoder

  defmodule State do
    @enforce_keys [:port]
    defstruct(
      port: nil,
      subscribers: []
    )
  end

  def start_link(device) do
    GenServer.start_link(__MODULE__, device)
  end

  @impl true
  def init(device) do
    args = decoder_key() ++ [device]
    port = Port.open({:spawn_executable, reader_executable()}, [:binary, {:args, args}])

    state = %State{port: port}

    {:ok, state}
  end

  @impl true
  def handle_info({port, {:data, bytes}}, %State{port: port} = state) do
    bytes
    |> Decoder.decode()
    |> inspect()
    |> Logger.debug()

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
