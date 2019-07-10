# Portfinder

[![Build Status](https://travis-ci.org/atshakil/portfinder.svg?branch=master)](https://travis-ci.org/atshakil/portfinder)
[![Gem Version](https://badge.fury.io/rb/portfinder.svg)](https://badge.fury.io/rb/portfinder)
[![Test Coverage](https://codeclimate.com/github/atshakil/portfinder/badges/coverage.svg)](https://codeclimate.com/github/atshakil/portfinder/coverage)
[![Inline docs](http://inch-ci.org/github/atshakil/portfinder.svg?branch=master)](http://inch-ci.org/github/atshakil/portfinder)
[![Code Climate](https://codeclimate.com/github/atshakil/portfinder/badges/gpa.svg)](https://codeclimate.com/github/atshakil/portfinder)
[![Issue Count](https://codeclimate.com/github/atshakil/portfinder/badges/issue_count.svg)](https://codeclimate.com/github/atshakil/portfinder)

## Summary

Portfinder is a ruby based port scanner with features like network/CIDR
scanning, port randomization, hostname discovery and banner grabbing.

## Installation

Portfinder installation is as simple as a gem installation can get.

```sh
gem install portfinder
```

## Usage

### As a CLI tool

```sh
portfinder <host> [--port=PORT] [--thread=THREAD] [--randomize]
  [--out=OUT_FILE] [--verbose]
```

`portfinder` can also be invoked using it's aliased form `pf`.

To it's simplest form, single port of a host can be scanned.

```sh
portfinder 192.168.1.1 -p 80
```

It is possible to scan multiple ports of a host. In this case, ports can be a
*range*,

```sh
portfinder 192.168.1.1 -p 1-1024
```

Or, a list of *selections*:

```sh
portfinder 192.168.1.1 -p 22,80,8080,443
```

Similarly, a scan can be performed on a selection of hosts,

```sh
portfinder 192.168.1.1,192.168.1.100,192.168.1.101 -p 1-65535
```

or, a range of hosts,

```sh
portfinder 192.168.1.1-10 -p 1-65535
```

or, on an entire network block, if you like.

```sh
portfinder 192.168.1.0/24 -p 1-65535
```

If a large number of host needs to be scanned, you may choose to increase the
number of concurrent scanners using the available `--thread` option.

```sh
portfinder 192.168.1.0/24 -p 1-65535 -t 20
```

By default, ten scanner threads are spawned at max.

When multiple ports are being scanned, they get scanned in the ascending order,
or in the provided port selection order. If a randomized scan order is expected,
`--randomize` flag can be utilized.

```sh
portfinder 192.168.1.0/24 -r
```

### As an API

A minimal usage example,

```ruby
require "portfinder"

scanner = Portfinder::Scanner.new("192.168.1.1", [22, 80, 8080], threads = 5)
scanner.scan
puts "\nOpen ports detected: #{scanner.result[host]}"
puts "Raw scan result: #{scanner.result}"
yml_stream = scanner.report_as "yml"
json_stream = scanner.json_report
```

It is possible to use the API in different modes,

#### Mode 1: Blocking mode with monitoring

```ruby
scanner =
  Portfinder::Scanner.new(
    hosts, ports,
    randomize: false, threaded: true, threads: 10, thread_for: :port
  )

scanner.log do |monitor|
  puts "Active threads:\t#{monitor.threads}\nScanning now:\n"
  while true
    print "\tHost:\t#{monitor.host}\tPort:\t#{monitor.port}\tStatus: #{
      monitor.state}\r"
    sleep 0.1
  end
end

scanner.scan
puts "\nScan complete!\n\nResult: #{scanner.generate_result}"

format = "json"
file = open("export.#{format}", "wb")
file.write scanner.report_as format.to_sym
file.close
```

#### Mode 2: Partial blocking (join during result invocation)

```ruby
scanner = Portfinder::Scanner.new("192.168.0.101", 1..65535)
#logger can be placed here...

scanner.scan synchronus = false

# logger can be placed here...
puts "\nScan complete!\n\nResult: #{scanner.generate_result}"
```

#### Mode 3 (GUI): Non-blocking (callback invocation upon completion)

(NOTE: Parent thread must be alive to receive callback)

```ruby
scanner = Portfinder::Scanner.new("192.168.0.101", 1..65535)

scanner.scan(false) do
  puts "\nScan complete!\n\nResult: #{scanner.generate_result}"
end

# logger can be placed here...

sleep 10
```

Please note that the default scanner scans TCP ports using a full handshake
(which is not, well..., stealthy. But, if you were expecting this feature, it's
gonna be available on the TCP SYN scanner release).

It's also worth noting that, the current implementation doesn't check for host
status (alive/dead). So, scan can be considerably slow for dead hosts.

## Contributing

If you are interested in contributing, please [submit a pull request](https://help.github.com/articles/about-pull-requests/).

## License

[MIT](http://opensource.org/licenses/MIT)
