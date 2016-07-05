require 'logger'
require 'cubic/redis_connection/pool'

module Cubic
  module Workers
    # The Base class for all workers
    #
    # @example
    #
    # require 'cubic'
    #
    # config = Cubic::Workers::Config.configure(path)
    # Cubic::Workers::Base.new(config).start
    # # will raise NotImplementedError
    #
    # There is Librato worker that inherit from Base
    # and if we start this worker, it will run successfully
    #
    # Cubic::Workers::Librato.new(config).start
    # # start the loops, load metrics and push to Librato
    class Base
      START_WORKER_MSG = "Starting the worker".freeze
      SHUTDOWN_TERM = "TERM".freeze

      attr_reader :config

      def initialize(config = {})
        @config = config
        register_signal
      end

      # One time run - for testing
      def rehearsal(&block)
        block.call if block
      end

      # Start the worker, only implemented in children classes
      #
      # Checkout the Librato worker as an example
      def start
        raise NotImplementedError
      end

      def perform(&block)
        log_info "Worker is starting..."

        loop do
          break if shutdown?
          sleep interval

          begin
            block.call if block
          rescue Exception => e
            log_error e.backtrace.join("\n")
            next
          end
        end
      end

      # Interval time in seconds
      #   Default is 1
      def interval
        @config[:interval] || 1
      end

      def log_error(msg)
        logger.error msg
      end

      def log_info(msg)
        logger.info msg
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end

      def shutdown?
        @shutdown
      end

      def shutdown!
        @shutdown = true
      end

      def register_signal
        Signal.trap(SHUTDOWN_TERM) do
          shutdown!
        end
      end
    end
  end
end
