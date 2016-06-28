require_relative './base'

module Cubic
  module Workers
    class Librato < Base
      Metric = Struct.new(:names, :values)

      KEY_PATTERN = "*".freeze

      def start
        perform do
          submit_librato load_redis_metrics
        end
      end

      def load_redis_metrics
        @pool.use do |conn|
          keys   = conn.keys KEY_PATTERN
          values = conn.mget keys

          Metric.new(keys, values)
        end
      end

      def redis_pool
        @pool ||= Redis::Pool.new(config)
      end

      def submit_librato(metrics)
        metrics.names.each_with_index do |name, i|
          librato_provider.val(name, metrics.values[i])
        end
      end

      def librato_provider
        @librato_provider ||= Providers::Librato.new(config)
      end
    end
  end
end
