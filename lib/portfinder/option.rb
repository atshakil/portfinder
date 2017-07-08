# FIXME: Slop doesn't raise an error during option parsing
module Slop
  # Slop parser for IPv4 Hosts
  class HostOption < Option
    def call value
      Portfinder::Parser.new.parse_hosts value
    end
  end

  # Slop parser for ports
  class PortOption < Option
    def call value
      Portfinder::Parser.new.parse_ports value
    end
  end

  # Slop parser for File path
  class OutOption < Option
    def call value
      File.basename value
    end
  end
end
