module Portfinder
  IP4_OCTET_ = /\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]/
  IP4_ = /((#{IP4_OCTET_})\.){3}(#{IP4_OCTET_})/
  CIDR_ = /\d|[12]\d|3[0-2]/
  IP4 = /^(?<ip>#{IP4_})$/
  IP4_RANGE = /^(?<start>#{IP4_})-(?<limit>[2-9]|[1-9]\d|1\d{2}|2[0-4]\d|
25[0-4])$/x
  IP4_SELECTION = /^(#{IP4_},)+#{IP4_}$/
  IP4_NETWORK = %r{^(?<network>#{IP4_})/(?<net_bits>#{CIDR_})$}

  PORT_ = /[1-9]|[1-9]\d|[1-9]\d{2}|[1-9]\d{3}|[1-5]\d{4}|6[0-4]\d{3}|
65[0-4]\d{2}|655[0-2]\d|6553[0-5]/x
  PORT = /^(?<port>#{PORT_})$/
  PORT_RANGE = /^(?<start>#{PORT_})-(?<end>#{PORT_})$/
  PORT_SELECTION = /^(#{PORT_},)+#{PORT_}$/

  # UNIX_FILE_ = /[^;:\|\/\0]+/
  # UNIX_DIR_ = //

  IP4_TYPES = {
    ip: Portfinder::IP4,
    range: Portfinder::IP4_RANGE,
    selection: Portfinder::IP4_SELECTION,
    network: Portfinder::IP4_NETWORK
  }.freeze
  PORT_TYPES = {
    port: Portfinder::PORT,
    range: Portfinder::PORT_RANGE,
    selection: Portfinder::PORT_SELECTION
  }.freeze
end
