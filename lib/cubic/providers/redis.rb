module Cubic
  module Providers
    class Redis
      DEFAULT_URL = "redis://localhost:6379/15".freeze

      attr_reader :pool

      def initialize(config)
        @url = config[:url] || DEFAULT_URL
        @pool = RedisConnection::Pool.new(@url)
      end

      def inc(label, by: 1)
        connection do |client|
          client.incrby(label, by)
        end
      end

      alias_method :counter, :inc

      def val(label, value)
        connection do |client|
          client.set(label, value)
        end
      end

      def connection(&block)
        client = pool.get_object

        block.call(client)
        pool.release(client)
      end
    end
  end
end
