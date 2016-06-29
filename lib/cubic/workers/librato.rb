require_relative './base'

module Cubic
  module Workers
    class Librato < Base
      Metric = Struct.new(:names, :values)

      KEY_PATTERN = "*".freeze

      def start
        perform do
          metrics = load_redis_metrics
          log_info metrics.to_s if metrics.names.any?

          submit_librato metrics
        end
      end

      def load_redis_metrics
        redis_pool.use do |conn|
          keys   = conn.keys KEY_PATTERN
          values = keys.any? ? conn.mget(keys) : []
          conn.del(keys) unless keys.empty?

          Metric.new(keys, values)
        end
      end

      def submit_librato(metrics)
        metrics.names.each_with_index do |name, i|
          librato_provider.val(name, metrics.values[i])
        end
      end

      def redis_pool
        @pool ||= RedisConnection::Pool.new(config)
      end

      def librato_provider
        @librato_provider ||= Providers::Librato.new(config)
      end
    end
  end
end
