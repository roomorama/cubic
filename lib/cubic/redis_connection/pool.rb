require 'redis'

module Cubic
  module RedisConnection
    class NoMoreConnectionError;end

    class Pool
      SIZE = 5

      def initialize(url, size = nil, klass = nil)
        @url = url
        @klass = klass || default_klass
        @size = size
      end

      # Request an Redis connection object from redis pool
      # Then do something with this connection object
      # Then return this object to the pool
      def use(&block)
        client = get_object

        result = block.call(client)
        release(client)
        result
      end

      def get_object
        obj = can_spawn? ? @klass.new(url: @url) : _available.shift
        raise NoMoreConnectionError unless obj

        _in_used << obj
        obj
      end

      def release(obj)
        _available << obj
        _in_used.delete obj
      end

      def can_spawn?
        _available.empty? && _in_used.size < pool_size
      end

      def pool_size
        @size || ENV['REDIS_POOL_SIZE'] || SIZE
      end

      def _available
        @_available ||= []
      end

      def _in_used
        @_in_used ||= []
      end

      def default_klass
        ::Redis
      end
    end
  end
end
