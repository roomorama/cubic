require_relative './base'
require_relative './config'

module Cubic
  module Workers
    class Librato < Base
      # Metric object store a list of metric names & values, getting from Redis
      Metric = Struct.new(:names, :values)

      # The key pattern will be use to get all keys from Redis DB
      KEY_PATTERN = "*".freeze

      # Start the worker
      #
      # Call the perform method in Base class, then execute these following tasks for
      # each iteration
      #
      #   1. Load metrics from Redis
      #   2. Log the metrics
      #   3. Submit to Librato queue
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
