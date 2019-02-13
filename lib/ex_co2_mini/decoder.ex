defmodule ExCO2Mini.Decoder do
  require Logger
  use Bitwise

  @moduledoc """
  Decodes packets from the CO₂Mini device.
  """

  @key [0xC4, 0xC6, 0xC0, 0x92, 0x40, 0x23, 0xDC, 0x96]

  @doc """
  Returns a list of eight integers, representing the eight-byte key used to
  communicate with the device.
  """
  def key, do: @key

  @doc """
  Decodes (and checksums) an eight-byte data packet received from the device.

  Returns `{key, value}`, where `key` is an 8-bit integer and `value` is a
  16-bit integer.

  Raises an error if the data packet does not pass the checksum routine.
  """

  def decode(<<data::bytes-size(8)>>) do
    data
    |> decrypt(@key)
    |> checksum!()
    |> extract()
  end

  defp decrypt(<<data::bytes-size(8)>>, key) do
    cstate = [0x48, 0x74, 0x65, 0x6D, 0x70, 0x39, 0x39, 0x65]
    shuffle = [2, 4, 0, 7, 1, 6, 5, 3]

    phase1 =
      shuffle
      |> Enum.map(&:binary.at(data, &1))

    phase2 =
      phase1
      |> Enum.zip(key)
      |> Enum.map(fn {p1, key} -> p1 ^^^ key end)

    phase3 =
      phase2
      |> shift_list(1)
      |> Enum.zip(phase2)
      |> Enum.map(fn {s_p2, p2} -> (p2 >>> 3 ||| s_p2 <<< 5) &&& 0xFF end)

    ctmp =
      cstate
      |> Enum.map(fn n -> (n >>> 4 ||| n <<< 4) &&& 0xFF end)

    out =
      phase3
      |> Enum.zip(ctmp)
      |> Enum.map(fn {p3, ct} -> 0x100 + p3 - ct &&& 0xFF end)

    :erlang.list_to_binary(out)
  end

  defp shift_list(list, shift) when shift > 0 do
    Enum.take(list, -shift) ++ Enum.drop(list, -shift)
  end

  defp checksum!(<<b1, b2, b3, b4, b5, b6, b7, b8>> = data) do
    cond do
      b5 != 0x0D ->
        raise "Checksum failed (b5): #{inspect(data)}"

      (b1 + b2 + b3 &&& 0xFF) != b4 ->
        raise "Checksum failed (b123 vs b4): #{inspect(data)}"

      {b6, b7, b8} != {0, 0, 0} ->
        raise "Checksum failed (b678): #{inspect(data)}"

      true ->
        data
    end
  end

  defp extract(<<key, value::size(16), _chksum, _0x0D, 0, 0, 0>>) do
    {key, value}
  end
end
