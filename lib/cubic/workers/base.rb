require 'cubic/redis_connection/pool'

module Cubic
  module Workers
    class Base
      START_WORKER_MSG = "Starting the worker".freeze

      def initialize(opts = {})
        @inteval = opts[:inteval]
      end

      # One time run - for testing
      def rehearsal(&block)
        perform(&block)
        shutdown!
      end

      def perform(&block)
        log :info, START_WORKER_MSG
        loop do
          break if shutdown?

          sleep interval

          begin
            block.call if block
          rescue Exception => e
            log :error, e.backtrace
            next
          end
        end
      end

      def interval
        @interval || 10
      end

      def log(severity = :info, message = nil)
        Logger.log severity, message
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end

      def shutdown?
        @shutdown
      end

      def shutdown
        @shutdown = true
      end
    end
  end
end
