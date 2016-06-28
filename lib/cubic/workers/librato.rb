require_relative './base'

module Cubic
  module Workers
    class Librato < Base
      KEY_PATTERN = "*".freeze

      def start
        perform do
        end
      end

      def load_redis_metrics
        @pool.use do |conn|
          conn.keys KEY_PATTERN
        end
      end

      def redis_pool
        @pool ||= Redis::Pool.new(config)
      end

      def submit_librato(label, value)
        librato_provider.val(label, value)
      end

      def librato_provider
        @librato_provider ||= Providers::Librato.new(config)
      end
    end
  end
end
