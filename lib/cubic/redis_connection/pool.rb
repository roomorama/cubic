require 'redis'

module Cubic
  module RedisConnection
    class NoMoreConnectionError;end

    class Pool
      SIZE = 5
      TIMEOUT = 1
      RECONNECT_ATTEMPTS = 3

      def initialize(config = {})
        @url = config[:url]
        @klass = config[:klass] || default_klass
        @size = config[:size]
      end

      # Request an Redis connection object from redis pool
      # Then do something with this connection object
      # Then return this object to the pool
      def use(&block)
        begin
          client = get_object

          result = block.call(client)
          result
        rescue Exception => e
          nil # TODO specify the Redis::ConnectionError instead
        ensure
          release(client)
        end
      end

      def get_object
        obj = can_spawn? ? @klass.new(url: @url, timeout: timeout, reconnect_attempts: reconnect_attempts) : _available.shift
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

      def timeout
        ENV['REDIS_TIMEOUT'] || TIMEOUT
      end

      def reconnect_attempts
        ENV['REDIS_RECONNECT_ATTEMPTS'] || RECONNECT_ATTEMPTS
      end
    end
  end
end
