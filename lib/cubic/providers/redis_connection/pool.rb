require 'redis'

module Cubic
  module Providers
    module RedisConnection
      class Pool
        SIZE = 5

        def initialize(url, size = nil, klass = nil)
          @url = url
          @klass = klass || default_klass
          @size = size
        end

        def get_object
          if _available.empty? && _in_used.size < pool_size
            obj = @klass.new(url: @url)
          else
            obj = _available.shift
          end

          raise "No more connection" unless obj

          _in_used << obj

          obj
        end

        def release(obj)
          _available << obj
          _in_used.delete obj
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
end
