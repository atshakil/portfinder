require "socket"
require "ipaddr"
require "json"
require "yaml"
require "portfinder/constants"
require "portfinder/error"
require "portfinder/parser"
require "portfinder/pool"
require "portfinder/monitor"
require "portfinder/scanner"
require "portfinder/version"

# Expectations

## Mode 1: Blocking mode with monitoring
# scanner = Portfinder::Scanner.new(hosts, ports,
#   randomize: false, threaded: true, threads: 10, thread_for: :port)
#
# scanner.log do |monitor|
#   puts "Active threads:\t#{monitor.threads}\nScanning now:\n"
#   while true
#     print "\tHost:\t#{monitor.host}\tPort:\t#{monitor.port}\tStatus: #{
#       monitor.state}\r"
#     sleep 0.1
#   end
# end
#
# scanner.scan
# puts "\nScan complete!\n\nResult: #{scanner.generate_result}"
#
# format = "json"
# file = open("meau.#{format}", "wb")
# file.write scanner.report_as format.to_sym
# file.close

## Mode 2: Partial blocking (join during result invocation)
# scanner = Portfinder::Scanner.new("192.168.0.101", 1..65535)
# #logger can be placed here...
#
# scanner.log do |monitor|
#   puts "Active threads:\t#{monitor.threads}\nScanning now:\n"
#   while true
#     print "\tHost:\t#{monitor.host}\tPort:\t#{monitor.port}\r"
#     sleep 0.1
#   end
# end
# scanner.scan synchronus = false
#
# # logger can be placed here
# puts "\nScan complete!\n\nResult: #{scanner.generate_result}"

## Mode 3: Non-blocking (callback invocation upon completion)
# (NOTE: Parent thread must be alive to receive callback)
#
# scanner = Portfinder::Scanner.new("192.168.0.101", 1..65535)
#
# scanner.scan(false) do
#   puts "\nScan complete!\n\nResult: #{scanner.generate_result}"
# end
#
# scanner.log do |monitor|
#   puts "Active threads:\t#{monitor.threads}\nScanning now:\n"
#   while true
#     print "\tHost:\t#{monitor.host}\tPort:\t#{monitor.port}\r"
#     sleep 0.1
#   end
# end
#
# sleep 10
