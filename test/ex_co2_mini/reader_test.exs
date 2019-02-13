defmodule ExCO2Mini.ReaderTest do
  use ExUnit.Case
  doctest ExCO2Mini.Reader
  alias ExCO2Mini.Reader

  @sample_data [
    {<<95, 228, 102, 32, 142, 70, 191, 186>>, {80, 701}},
    {<<64, 228, 95, 32, 215, 70, 191, 66>>, {79, 7130}},
    {<<187, 228, 119, 32, 181, 70, 191, 210>>, {82, 10009}},
    {<<112, 228, 238, 32, 252, 70, 191, 42>>, {65, 0}},
    {<<184, 228, 254, 32, 84, 70, 191, 122>>, {67, 3065}},
    {<<189, 228, 246, 32, 8, 70, 191, 138>>, {66, 4729}},
    {<<234, 228, 78, 33, 181, 70, 191, 90>>, {109, 1807}},
    {<<12, 228, 81, 33, 167, 70, 191, 242>>, {110, 26083}},
    {<<88, 228, 110, 33, 142, 70, 191, 162>>, {113, 701}},
    {<<95, 228, 102, 32, 142, 70, 191, 186>>, {80, 701}},
    {<<130, 228, 31, 32, 253, 70, 191, 106>>, {87, 8210}},
    {<<107, 228, 23, 32, 181, 70, 191, 2>>, {86, 10015}},
    {<<112, 228, 238, 32, 252, 70, 191, 42>>, {65, 0}},
    {<<184, 228, 254, 32, 84, 70, 191, 122>>, {67, 3065}},
    {<<189, 228, 246, 32, 8, 70, 191, 138>>, {66, 4729}},
    {<<234, 228, 78, 33, 181, 70, 191, 90>>, {109, 1807}},
    {<<28, 228, 81, 33, 167, 70, 191, 226>>, {110, 26085}},
    {<<72, 228, 110, 33, 142, 70, 191, 178>>, {113, 699}},
    {<<79, 228, 102, 32, 142, 70, 191, 138>>, {80, 699}},
    {<<168, 228, 95, 32, 215, 70, 191, 42>>, {79, 7127}},
    {<<179, 228, 119, 32, 181, 70, 191, 170>>, {82, 10008}},
    {<<112, 228, 238, 32, 252, 70, 191, 42>>, {65, 0}},
    {<<184, 228, 254, 32, 84, 70, 191, 122>>, {67, 3065}},
    {<<189, 228, 246, 32, 8, 70, 191, 138>>, {66, 4729}},
    {<<234, 228, 78, 33, 181, 70, 191, 90>>, {109, 1807}},
    {<<28, 228, 81, 33, 167, 70, 191, 226>>, {110, 26085}},
    {<<72, 228, 110, 33, 142, 70, 191, 178>>, {113, 699}},
    {<<79, 228, 102, 32, 142, 70, 191, 138>>, {80, 699}},
    {<<139, 228, 31, 32, 253, 70, 191, 146>>, {87, 8211}},
    {<<3, 228, 23, 32, 181, 70, 191, 58>>, {86, 10018}},
    {<<112, 228, 238, 32, 252, 70, 191, 42>>, {65, 0}},
    {<<184, 228, 254, 32, 84, 70, 191, 122>>, {67, 3065}},
    {<<189, 228, 246, 32, 8, 70, 191, 138>>, {66, 4729}},
    {<<234, 228, 78, 33, 181, 70, 191, 90>>, {109, 1807}},
    {<<36, 228, 81, 33, 167, 70, 191, 234>>, {110, 26086}},
    {<<72, 228, 110, 33, 142, 70, 191, 178>>, {113, 699}},
    {<<79, 228, 102, 32, 142, 70, 191, 138>>, {80, 699}},
    {<<168, 228, 95, 32, 215, 70, 191, 42>>, {79, 7127}},
    {<<147, 228, 119, 32, 181, 70, 191, 138>>, {82, 10004}},
    {<<112, 228, 238, 32, 252, 70, 191, 42>>, {65, 0}},
    {<<64, 228, 254, 32, 84, 70, 191, 98>>, {67, 3066}},
    {<<189, 228, 246, 32, 8, 70, 191, 138>>, {66, 4729}},
    {<<226, 228, 78, 33, 181, 70, 191, 82>>, {109, 1806}},
    {<<36, 228, 81, 33, 167, 70, 191, 234>>, {110, 26086}},
    {<<72, 228, 110, 33, 142, 70, 191, 178>>, {113, 699}},
    {<<79, 228, 102, 32, 142, 70, 191, 138>>, {80, 699}},
    {<<250, 228, 31, 32, 253, 70, 191, 98>>, {87, 8209}},
    {<<19, 228, 23, 32, 181, 70, 191, 42>>, {86, 10020}},
    {<<112, 228, 238, 32, 252, 70, 191, 42>>, {65, 0}},
    {<<64, 228, 254, 32, 84, 70, 191, 98>>, {67, 3066}},
    {<<189, 228, 246, 32, 8, 70, 191, 138>>, {66, 4729}},
    {<<226, 228, 78, 33, 181, 70, 191, 82>>, {109, 1806}},
    {<<44, 228, 81, 33, 167, 70, 191, 18>>, {110, 26087}},
    {<<64, 228, 110, 33, 142, 70, 191, 138>>, {113, 698}},
    {<<71, 228, 102, 32, 142, 70, 191, 130>>, {80, 698}},
    {<<168, 228, 95, 32, 215, 70, 191, 42>>, {79, 7127}},
    {<<171, 228, 119, 32, 181, 70, 191, 162>>, {82, 10007}},
    {<<112, 228, 238, 32, 252, 70, 191, 42>>, {65, 0}},
    {<<64, 228, 254, 32, 84, 70, 191, 98>>, {67, 3066}},
    {<<189, 228, 246, 32, 8, 70, 191, 138>>, {66, 4729}},
    {<<226, 228, 78, 33, 181, 70, 191, 82>>, {109, 1806}},
    {<<44, 228, 81, 33, 167, 70, 191, 18>>, {110, 26087}},
    {<<64, 228, 110, 33, 142, 70, 191, 138>>, {113, 698}},
    {<<71, 228, 102, 32, 142, 70, 191, 130>>, {80, 698}},
    {<<250, 228, 31, 32, 253, 70, 191, 98>>, {87, 8209}},
    {<<123, 228, 23, 32, 181, 70, 191, 50>>, {86, 10017}},
    {<<112, 228, 238, 32, 252, 70, 191, 42>>, {65, 0}},
    {<<64, 228, 254, 32, 84, 70, 191, 98>>, {67, 3066}},
    {<<189, 228, 246, 32, 8, 70, 191, 138>>, {66, 4729}}
  ]

  defmodule MockSubscriber do
    def child_spec(id) do
      %{
        id: id,
        restart: :temporary,
        start: {__MODULE__, :start_link, [self(), id]}
      }
    end

    def start_link(parent, id) do
      Task.start_link(fn ->
        receive_loop(parent, id)
      end)
    end

    defp receive_loop(parent, id) do
      receive do
        {reader, packet} -> send(parent, {id, reader, packet})
      end

      receive_loop(parent, id)
    end
  end

  test "sends decoded value to subscribers" do
    {:ok, sub1} = start_supervised({MockSubscriber, :sub1})
    {:ok, sub2} = start_supervised({MockSubscriber, :sub2})
    {:ok, sub3} = start_supervised({MockSubscriber, :sub3})

    opts = [device: :dummy, subscribers: [sub1, sub2, sub3]]
    {:ok, reader} = start_supervised({Reader, opts})

    Enum.shuffle(@sample_data)
    |> Enum.each(fn {raw, {key, value}} ->
      send(reader, {:dummy, {:data, raw}})

      assert_receive {:sub1, ^reader, {^key, ^value}}
      assert_receive {:sub2, ^reader, {^key, ^value}}
      assert_receive {:sub3, ^reader, {^key, ^value}}
    end)
  end

  test "subscribe/1 adds to subscribers" do
    {:ok, reader} = start_supervised({Reader, device: :dummy})
    {:ok, sub1} = start_supervised({MockSubscriber, :sub1})
    {:ok, sub2} = start_supervised({MockSubscriber, :sub2})

    # Add the first subscriber:
    Reader.subscribe(reader, sub1)
    {raw, {key, value}} = Enum.random(@sample_data)
    send(reader, {:dummy, {:data, raw}})
    assert_receive {:sub1, ^reader, {^key, ^value}}

    # Add the second subscriber:
    Reader.subscribe(reader, sub2)
    {raw, {key, value}} = Enum.random(@sample_data)
    send(reader, {:dummy, {:data, raw}})
    assert_receive {:sub1, ^reader, {^key, ^value}}
    assert_receive {:sub2, ^reader, {^key, ^value}}
  end

  test "subscribe/1 ignores duplicate subscription requests" do
    {:ok, sub} = start_supervised({MockSubscriber, :sub})
    {:ok, reader} = start_supervised({Reader, device: :dummy})

    Reader.subscribe(reader, sub)
    Reader.subscribe(reader, sub)
    Reader.subscribe(reader, sub)

    Enum.shuffle(@sample_data)
    |> Enum.each(fn {raw, {key, value}} ->
      send(reader, {:dummy, {:data, raw}})
      # If it's sending multiple requests, this will fail when it gets the
      # first packet on the second iteration:
      assert_receive {:sub, ^reader, {^key, ^value}}
    end)
  end

  test "subscribe/1 accepts a named process (atom)" do
    {:ok, sub} = start_supervised({MockSubscriber, :sub})
    {:ok, reader} = start_supervised({Reader, device: :dummy})

    Process.register(sub, MyMockSubscriber)
    Reader.subscribe(reader, MyMockSubscriber)

    Enum.shuffle(@sample_data)
    |> Enum.each(fn {raw, {key, value}} ->
      send(reader, {:dummy, {:data, raw}})
      assert_receive {:sub, ^reader, {^key, ^value}}
    end)
  end

  test "start_link/1 with send_from_name uses name in data packets" do
    opts = [
      device: :dummy,
      name: MyReader,
      send_from_name: true,
      subscribers: [self()]
    ]

    {:ok, reader} = start_supervised({Reader, opts})

    Enum.shuffle(@sample_data)
    |> Enum.each(fn {raw, {key, value}} ->
      send(reader, {:dummy, {:data, raw}})
      assert_receive {MyReader, {^key, ^value}}
    end)
  end

  test "exits if wrapper fails to start" do
    Process.flag(:trap_exit, true)
    {:ok, reader} = Reader.start_link(device: "fail-quietly")
    assert_receive {:EXIT, ^reader, message}
    assert message =~ "Reader port has died"
  end
end
