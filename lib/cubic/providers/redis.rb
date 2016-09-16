require 'cubic/redis_connection/pool'

module Cubic
  module Providers
    class Redis
      DEFAULT_URL = "redis://localhost:6379/15".freeze
      SANITIZED_REGEX = /[^A-Za-z0-9|\.|\_|:|-]/

      attr_reader :pool

      # Initializes a new instance of +Cubic::Providers::Redis+
      #
      #   config - the hash passed as +provider_options+
      #
      # This provider will use these following options:
      #
      # * url - Redis url
      #   This url follow ruby +URI+, with the scheme +redis+
      #   E.g. redis://:p4ssw0rd@10.0.1.1:6380/15
      #
      #   Check out more information at
      #   https://github.com/redis/redis-rb#getting-started
      #
      # * namespace  - a prefix to be used in all labels prior to sending to Librato [optional]
      def initialize(config)
        @namespace = config[:namespace]
        @pool = RedisConnection::Pool.new(config)
      end

      def inc(label, by: 1)
        pool.use do |client|
          client.incrby(namespaced(label), by)
        end
      end

      alias_method :counter, :inc

      def val(label, value)
        pool.use do |client|
          client.set(namespaced(label), value)
        end
      end

      def time(label)
        start = Time.now
        result = yield
      ensure
        duration_in_ms = ((Time.now - start) * 1000).round
        val(label, duration_in_ms)
        result
      end

      # DUPLICATE FOR NOW - WILL REFACTOR
      def namespaced(label)
        namespace = if @namespace
          [@namespace, label].join(".")
        else
          label
        end

        sanitize namespace
      end

      def sanitize(namespace)
        namespace.gsub(SANITIZED_REGEX, '')
      end
    end
  end
end
