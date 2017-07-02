module Portfinder
  # Portfinder scanner monitor
  class Monitor
    attr_reader :state
    attr_accessor :host
    attr_accessor :port
    attr_accessor :threads

    def initialize state = :init
      self.state = state
      @host = ""
      @port = nil
      @threads = 1
    end

    # Refactor: Enum?
    def state= value
      states = %i[init run term]
      unless states.include?(value)
        raise TypeError, "state can be any of #{states}"
      end
      @state = value
    end

    def start
      self.state = :run
      reset
    end

    def stop
      self.state = :term
      reset
    end

    def update host, port
      @host = host
      @port = port
    end

    private

    def reset
      @host = ""
      @port = nil
      @threads = 1
    end
  end
end
