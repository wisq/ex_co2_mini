defmodule ExCO2Mini.DecoderTest do
  use ExUnit.Case
  doctest ExCO2Mini.Decoder
  alias ExCO2Mini.Decoder

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

  test "decodes sample data" do
    Enum.each(@sample_data, fn {bytes, expected} ->
      actual = Decoder.decode(bytes)
      assert expected == actual
    end)
  end

  test "fails checksum if any byte is modified" do
    Enum.each(@sample_data, fn {real, _} ->
      fake = munge_random_byte(real)

      assert_raise(RuntimeError, ~r{^Checksum failed }, fn ->
        Decoder.decode(fake)
      end)
    end)
  end

  defp munge_random_byte(<<bytes::bytes-size(8)>>) do
    pos = Enum.random(0..7)
    old = :binary.at(bytes, pos)
    new = random_byte_except(old)
    replace_byte(bytes, pos, new)
  end

  defp random_byte_except(old) do
    case Enum.random(0..255) do
      ^old -> random_byte_except(old)
      other -> other
    end
  end

  defp replace_byte(bytes, pos, new) do
    bytes
    |> :binary.bin_to_list()
    |> List.replace_at(pos, new)
    |> :binary.list_to_bin()
  end
end