module Portfinder
  # Argument parser
  class Parser
    # Parser match type
    Type = Struct.new :name, :match

    def initialize; end

    # :reek:FeatureEnvy
    def parse_hosts target
      type = select_type target, IP4_TYPES
      return unless type

      case type.name
      when :ip
        type.match[:ip]
      when :range
        ip4_range type.match[:start], type.match[:limit].to_i
      when :selection
        target.split ","
      when :network
        ip4_network_hosts type.match[:network], type.match[:net_bits].to_i
      end
    end

    # :reek:FeatureEnvy
    def parse_ports target
      type = select_type target, PORT_TYPES
      return unless type

      case type.name
      when :port
        type.match[:port].to_i
      when :range
        type.match[:start].to_i..type.match[:end].to_i
      when :selection
        target.split(",").map(&:to_i)
      end
    end

    def parse_file_path _target, _verify = false
      raise NotImplementedError, "Implementation pending"
    end

    def parse_dir_path _target, _verify = false
      raise NotImplementedError, "Implementation pending"
    end

    private

    def ip4_range start, limit
      start_offset = start.split(".").last.to_i
      host_count = (limit - start_offset) + 1
      host_count_in_range = (1..254).cover? host_count
      last_host_in_range = (2..254).cover? limit

      return unless host_count_in_range && last_host_in_range

      Enumerator.new host_count do |host|
        IPAddr.new(
          start + "/24"
        ).to_range.each_with_index do |addr, index|
          host << addr.to_s if (start_offset..limit).cover? index
        end
      end
    end

    def ip4_network_hosts network, net_bits
      ip_count = 2**(32 - net_bits)
      valid_host_count = ip_count < 2 ? 0 : ip_count - 2
      range = IPAddr.new("#{network}/#{net_bits}").to_range
      exceptions = [range.first, range.last]
      Enumerator.new valid_host_count do |host|
        range.each do |addr|
          host << addr.to_s unless exceptions.include?(addr)
        end
      end
    end

    def select_type target, types
      selection_type = nil

      types.each_pair do |type, matcher|
        match = matcher.match(target)
        selection_type = Type.new(type, match) if match
      end

      selection_type
    end
  end
end
