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

  @ctmp [0x48, 0x74, 0x65, 0x6D, 0x70, 0x39, 0x39, 0x65]
        |> Enum.map(fn n -> (n >>> 4 ||| n <<< 4) &&& 0xFF end)
  @shuffle [2, 4, 0, 7, 1, 6, 5, 3]

  # Honestly, this is pretty voodoo.
  # It's taken directly from the hackaday.io project,
  # but reformulated to more Elixir-style transformations.
  defp decrypt(<<data::bytes-size(8)>>, key) do
    @shuffle
    # Use @shuffle as a list of indices to extract:
    |> Enum.map(&:binary.at(data, &1))
    # XOR with the key:
    |> Enum.zip(key)
    |> Enum.map(fn {p1, key} -> p1 ^^^ key end)
    # Zip indices [7, 0..6] (shifted) with indices [0..7] (plain)
    |> zip_with_shifted_list(1)
    # Take shifted (sx) + plain (x) and do some bitwise math on them:
    |> Enum.map(fn {sx, x} -> (x >>> 3 ||| sx <<< 5) &&& 0xFF end)
    # Zip with @ctmp and do more bitwise math:
    |> Enum.zip(@ctmp)
    |> Enum.map(fn {x, ct} -> 0x100 + x - ct &&& 0xFF end)
    # Finally, dump to a binary (note: not `String`!) again.
    |> :erlang.list_to_binary()
  end

  defp zip_with_shifted_list(list, shift) do
    shift_list(list, shift)
    |> Enum.zip(list)
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
