module Cubic
  module Providers

    class Memory
      attr_reader :storage

      def initialize(*)
        @storage = {}
      end

      def inc(label, by: 1)
        storage[label] ||= 0
        storage[label] += by
      end

      def val(label, value)
        storage[label] ||= []
        storage[label] << value
      end

      def time(label)
        start = Time.now
        yield
      ensure
        duration_in_ms = ((Time.now - start) * 1000).round
        val(label, duration_in_ms)
      end

      def transaction
        yield
      end

      def query(label)
        storage[label]
      end

    end

  end
end
