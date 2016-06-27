module Cubic
  module Providers
    class Redis
      DEFAULT_URL = "redis://localhost:6379/15".freeze

      def initialize(config)
        @url = config[:url] || DEFAULT_URL
      end

      def inc(label, by: 1)
        client.incrby(label, by)
      end

      alias_method :counter, :inc

      def val(label, value)
        client.set(label, value)
      end

      def client
        pool.get_instance
      end

      def pool
        @pool ||= Redis::Pool.new(@url)
      end
    end
  end
end
