require 'logger'
require 'cubic/redis_connection/pool'

module Cubic
  module Workers
    class Base
      START_WORKER_MSG = "Starting the worker".freeze

      attr_reader :config

      def initialize(config = {})
        @config = config
      end

      # One time run - for testing
      def rehearsal(&block)
        block.call if block
      end

      def perform(&block)
        loop do
          break if shutdown?
          sleep interval

          begin
            block.call if block
          rescue Exception => e
            log_error e.backtrace
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
    end
  end
end
