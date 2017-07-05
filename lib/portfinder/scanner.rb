module Portfinder
  # Portfinder Scanner base class
  class Scanner
    # Provides access to raw scan result
    attr_reader :result
    # Readonly port randomization flag
    attr_reader :randomize
    # Scan monitor accessor for in-scan monitoring and logging (readonly)
    attr_reader :monitor

    # Scanner initializer
    def initialize target, port, config = {
      randomize: true, threaded: true, threads: 10, thread_for: :port
    }
      @hosts = host_range target
      @randomize = config[:randomize]
      @ports = port_range port
      @threaded = config[:threaded]
      @thread_for = config[:thread_for]
      @result = {}
      @monitor = Monitor.new
      @pool =
        Pool.new(
          threads_to_open(
            @thread_for, config[:threads], @hosts, @ports
          )
        )
    end

    # Scans host(s) according to provided specification
    def scan synchronus = true, &callback
      @monitor.start
      if @threaded
        case @thread_for
        when :ip
          scan_threaded_ip
        when :port
          scan_threaded_port
        end

        if synchronus
          @pool.shutdown
          @monitor.stop
        elsif callback
          @pool.shutdown(false) do
            callback.call
            @monitor
          end
        end
      else
        synchronus_scan
      end
    end

    # Defines a logger (accepts logger as a block)
    def log &logger
      Thread.new { logger.call @monitor }
    end

    # Generates scan result in the specified format
    def generate_result pretty = false
      @result = @pool.complete_result if @threaded
      pretty ? pretty_print(@result) : @result
    end

    # Generates a report in the specified format from the scan result
    def report_as format
      case format
      when :json
        JSON.pretty_generate @result
      when :yml
        YAML.dump @result
      else
        raise ArgumentError, "Unknown format: #{format}"
      end
    end

    # Generates a JSON report
    def json_report
      report_as :json
    end

    # Generates a YAML report
    def yml_report
      report_as :yml
    end

    private

    def pretty_print result
      formatted = "Scan complete!\n\n"
      result.keys.each do |ip|
        ports = result[ip].to_s.gsub(/[\[\]]/, "")
        formatted << "IP: #{ip}\n\tOpen ports: #{ports}\n\n"
      end

      formatted
    end

    def scannable_pairs hosts, ports
      Enumerator.new(hosts.size * ports.size) do |pair|
        hosts.each do |host|
          ports.each do |port|
            pair << [host, port]
          end
        end
      end
    end

    def threads_to_open thread_for, max, hosts, ports
      case thread_for
      when :ip
        host_count = hosts.size
        host_count > max ? max : host_count
      when :port
        tasks = scannable_pairs(hosts, ports).size
        tasks > max ? max : tasks
      end
    end

    def host_range target
      type = target.class
      if [Array, Enumerator].include? type
        target
      elsif type == String
        [target]
      else
        []
      end
    end

    # :reek:FeatureEnvy
    def port_range port
      port = port.dup
      port = [port] if port.class == Integer
      @randomize ? port.to_a.shuffle : port
    end

    def scan_threaded_ip
      @monitor.threads = @pool.size
      @pool.result_format do |result, args, value|
        result = result.dup
        if value.any?
          host = args[0]
          result[host] = value
        end
        result
      end

      @hosts.each do |host|
        @pool.schedule host do
          open_ports = []
          @ports.each do |port|
            @monitor.update host, port
            open_ports << port if port_open? host, port
          end
          open_ports.sort
        end
      end
    end

    def scan_threaded_port
      @monitor.threads = @pool.size
      @pool.result_format do |result, args, value|
        result = result.dup
        if value
          host = args[0][0]
          ports = result[host]
          result[host] = ports ? ports.push(value).sort : [value]
        end
        result
      end

      scannable_pairs(@hosts, @ports).each do |pair|
        @pool.schedule(pair) do
          @monitor.update(*pair)
          port_open?(*pair)
        end
      end
    end

    def scan_synchronized_port
      scannable_pairs(@hosts, @ports).each do |pair|
        host, port = pair
        @monitor.update(*pair)

        if port_open?(*pair)
          ports = @result[host]
          @result[host] = ports ? ports.push(port).sort : [port]
        end
      end
    end

    def synchronus_scan
      scan_synchronized_port
      @monitor.stop
    end

    def port_open? host, port
      socket = Socket.new :INET, :STREAM, 0
      address = Socket.pack_sockaddr_in(port, host)

      begin
        socket.connect address
        socket.close
        port
      rescue StandardError
        nil
      end
    end
  end
end
