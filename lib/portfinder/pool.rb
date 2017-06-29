module Portfinder
  # Portfinder Thread pool
  class Pool
    attr_reader :result
    attr_reader :size

    def initialize size
      @pool = []
      @size = size
      @jobs = Queue.new
      @result = {}
      @formatter = nil
      process
    end

    def complete_result
      shutdown
      @result
    end

    def result_format &block
      @formatter = block
    end

    def schedule *args, &block
      @jobs << [block, args]
    end

    def shutdown synchronize = true, &callback
      @size.times do
        schedule { throw :shutdown }
      end

      watcher =
        Thread.fork do
          @pool.map(&:join)
          callback.call if callback
        end

      watcher.join if synchronize
    end

    private

    def process
      @pool = Array.new(@size) do
        Thread.fork do
          catch :shutdown do
            loop do
              job, args = @jobs.pop
              value = job.call args
              @result = @formatter.call(@result, args, value) if @formatter
            end
          end
        end
      end
    end
  end
end
