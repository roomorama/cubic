require_relative './base'

module Cubic
  module Workers
    class Librato < Base
      def start
        perform do
        end
      end

      def load_redis_metrics
        @_conn.
      end

      def redis_connection
        @_conn = @pool.get_object
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
