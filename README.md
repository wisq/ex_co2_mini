# ExCO₂Mini

ExCO₂Mini is a library to read carbon dioxide and temperature data from the CO₂Mini USB sensor, also known as the RAD-0301.

This library only reads data from the device.  If you want to record that data somewhere, see e.g. [ddco2](https://github.com/wisq/ddco2) for recording to StatsD.

[![Build Status](https://travis-ci.org/wisq/ex_co2_mini.svg?branch=master)](https://travis-ci.org/wisq/ex_co2_mini)
[![Hex.pm Version](http://img.shields.io/hexpm/v/ex_co2_mini.svg?style=flat)](https://hex.pm/packages/ex_co2_mini)

## Device setup

**ExCO₂Mini currently only supports Linux.**  Your device needs to show up as a `/dev/hidraw*` device, and it needs to be able to compile a small C utility that uses Linux-specific HID ioctls.

To allow a regular user to access the device, you can set up a `udev` rule, such as the following:

```udev
KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a052", GROUP="co2meter", MODE="0640", SYMLINK+="co2mini"
```

(Don't forget to `udevadm control --reload-rules`.)

When the device is plugged in, this will set the device's group to `co2meter`, set group read (`g+r`) permissions on it, and create a `/dev/co2mini` symlink to it.  (Write permissions are not required.)

Note that the device will often report abnormally high readings immediately after being plugged in, then settle down to a more reasonable number.

## Installation

ExCO₂Mini is [available in Hex](https://hex.pm/packages/ex_co2_mini).

If you haven't already, start a project with `mix new`.

Then, add `ex_co2_mini` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_co2_mini, "~> 0.1.1"}
  ]
end
```

Run `mix deps.get` to pull ExCO₂Mini into your project, and you're good to go.

## Usage

```elixir
# Connect to the device and start reading data:
{:ok, reader} = ExCO2Mini.Reader.start_link(device: "/dev/co2mini")
# Subscribe to the Reader to start receiving raw data:
ExCO2Mini.Reader.subscribe(reader)
# Receive messages (do this repeatedly):
receive do
  {^reader, {key, value}} -> Logger.debug("received #{key}=#{value}")
end

# Attach a Collector to the Reader to get data on demand:
{:ok, collector} = ExCO2Mini.Collector.start_link(reader: reader)
# Give it a few seconds to collect data:
Process.sleep(5_000)
# Now you should be able to retrieve CO₂ (parts per million)
# and temperature (degrees Celsius) data:
co2 = ExCo2Mini.Collector.co2_ppm(collector)
temp = ExCO2Mini.Collector.temperature(collector)
Logger.info("CO₂ = #{co2} ppm, temperature = #{temp} °C")
```

### Supervised Usage

If you want to set up a Reader and a Collector in a Supervisor, you can give them names and tell each to connect to the other.  This will ensure that they continue to communicate even if one or the other is restarted:

```elixir
children = [
  {ExCO2Mini.Reader,
   [
     name: MyApp.Reader,
     subscribers: [MyApp.Collector],
     send_from_name: true,
     device: "/dev/co2mini"
   ]},
  {ExCO2Mini.Collector,
   [
     name: MyApp.Collector,
     reader: MyApp.Reader,
     subscribe_as_name: true
   ]}
]

Supervisor.start_link(
  children,
  strategy: :one_for_one,
  name: MyApp.Supervisor
)
```

Using `send_from_name` will ensure that the Reader sends messages using its `name` option — i.e. messages will look like `{MyApp.Reader, {key, value}}` — and `subscribe_as_name` will ensure that the Collector subscribes using its own `name` value (so the Reader can track it if it restarts).

See [ddco2](https://github.com/wisq/ddco2) for an example of this usage.

## Documentation

Full documentation can be found at [https://hexdocs.pm/ex_co2_mini](https://hexdocs.pm/ex_co2_mini).

## Legal stuff

Copyright © 2019, Adrian Irving-Beer.

Parts of this code are based on code and data from the ["Reverse-Engineering a low-cost USB CO₂ monitor" project](https://hackaday.io/project/5301-reverse-engineering-a-low-cost-usb-co-monitor).  My thanks go out to Henryk Plötz, whose reverse engineering made this project possible.

ExCO₂Mini is released under the [Apache 2 License](https://github.com/wisq/ex_co2_mini/blob/master/LICENSE) and is provided with **no warranty**.  This library is aimed at hobbyists and home enthusiasts, and should be used in **non-life-critical situations only**.
