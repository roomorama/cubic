require 'cubic/redis_connection/pool'

module Cubic
  module Providers
    class Redis
      DEFAULT_URL = "redis://localhost:6379/15".freeze

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
        @url = config[:url] || DEFAULT_URL
        @namespace = config[:namespace]
        @pool = RedisConnection::Pool.new(@url)
      end

      def inc(label, by: 1)
        connection do |client|
          client.incrby(namespaced(label), by)
        end
      end

      alias_method :counter, :inc

      def val(label, value)
        connection do |client|
          client.set(namespaced(label), value)
        end
      end

      # Request an Redis connection object from redis pool
      # Then do something with this connection object
      # Then return this object to the pool
      def connection(&block)
        client = pool.get_object

        block.call(client)
        pool.release(client)
      end

      # DUPLICATE FOR NOW - WILL REFACTOR
      def namespaced(label)
        if @namespace
          [@namespace, label].join(".")
        else
          label
        end
      end
    end
  end
end
